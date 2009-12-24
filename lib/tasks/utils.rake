require 'curb'

namespace :utils do
  desc "Create time machine images for active boards"
  task(:generate_time_machine_images => :environment) do
    Element.boards.find(:all, :conditions => "status_id = #{STATUS_ACTIVE}").each do |board|
      board.log!(DateTime.parse(1.days.ago.strftime('%D 23:59:59')))
      puts "Rendering Time Machine for #{board.id} on #{board.time_machine.strftime('%D %r')}"
      EagleEye.new(board).render
    end
  end

  desc "move user avatars to S3 with IDs instead of logins"
  task(:migrate_avatars => :environment) do
    User.all.each do |user|
      if user.avatar_url =~ /#{user.login}/
        avatar_path = "user-#{user.id}-#{user.created_at.to_i}.#{/(.*\.)(.*$)/.match(user.avatar_url)[2]}"

        file_path = "#{RAILS_ROOT}/public/temp_avatars/#{avatar_path}"

        file = File.open(file_path, 'wb')
        file.write(Curl::Easy.perform(user.avatar_url).body_str)
        file.close
        puts "Migrating: #{user.id} - #{user.login}"
        User.update_attribute(:avatar_url, S3Interface.save_to_s3(file_path, avatar_path))
        FileUtils.rm(file_path)
      end
    end
  end


  desc "adds the necessary hosts to your local /etc/hosts file from current subdomains in db"
  task :subdomains => :environment do
    #
    #  emptyblog.localhost used as a locator for the line in /etc/hosts
    tmp_file, changed = '/tmp/etc_hosts_copy', false
    default, hosts = %w[skinnyboard.local www.skinnyboard.local], []

    # add all the blog subdomains
    Company.find(:all).each { |c| hosts << "#{c.subdomain}.skinnyboard.local" }

    host_line = "127.0.0.1 " + hosts.sort.unshift(default).join(' ')

    %x[cp /etc/hosts #{tmp_file}]

    file = File.new(tmp_file)
    lines = file.readlines
    lines.each do |line|
      changed = true if line.gsub!(/^127.0.0.1 skinnyboard\.local www\.skinnyboard\.local.+$/, host_line)
    end

    unless changed
      lines += ["\n", host_line, "\n"]
    end

    file = File.new(tmp_file,'w')
    lines.each do |line|
      file.write(line)
    end
    file.close

    %x[sudo -p "Password:" cp #{tmp_file} /etc/hosts]
    puts "subdomains finished"
    puts "They are available as;\n\n"
    hosts.each do |host|
      puts "http://#{host}"
    end
    puts "\n"
  end
end