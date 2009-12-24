# Methods added to this helper will be available to all templates in the application.

module ApplicationHelper
  # Recaptcha stuff
  include ReCaptcha::ViewHelper if RECAPTCHA
  
  def user_name
    @person = "[User Name Goes Here]"
  end
  
  def insert_google_analytics
    render :partial => 'account/google_anal' if GOOGLE_ANAL
  end
  
  def toggle(object_to_toggle)
    "javascript:Effect.toggle('#{object_to_toggle}', 'appear');"
  end
  
  def display_flash(flash)
    #hide our flashes initially
    page.hide 'flash_notice'
    page.hide 'flash_error'

    [:errors, :notice].each { |flash_type| flash_displayer(flash, flash_type) }
  end

  # def active_boards
  #   unless current_user == :false
  #     boards = Element.find_all_by_user_permissions_and_active(current_user, false).sort{|a, b| a.title.downcase <=> b.title.downcase}
  #     collection_select("boards", "title", boards, "id", "title", {:prompt => "Jump To a Board"}, {:onchange => "jumpToBoard(this.value);"})
  #   end
  # end

private
  def flash_displayer(flash, type)
    unless flash[type].blank?
      page.show "flash_#{type.to_s}"
      page.replace_html "flash_#{type.to_s}", flash[type]
    end
  end
  
end