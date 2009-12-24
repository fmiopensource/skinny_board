class S3Interface
  def self.save_to_s3(file, filename = file, streamed = false)
    init(file)
    
    begin
      AWS::S3::Bucket.find(AMAZON_BUCKET)
    rescue ResponseError => error
      #If find fails, bucket doesn't exist so we need to create it
      AWS::S3::Bucket.create(AMAZON_BUCKET)
    end

    AWS::S3::S3Object.store(filename, streamed ? file : open(file), AMAZON_BUCKET, :access => :public_read)
    
    #return the URL for the created object
    AWS::S3::S3Object.url_for(filename, AMAZON_BUCKET, :authenticated => false)
  end

  def self.retrieve_from_s3(file)
    init(file)
    
    if AWS::S3::S3Object.exists? file, AMAZON_BUCKET
      AWS::S3::S3Object.url_for(file, AMAZON_BUCKET, :authenticated => false)
    else
      nil
    end
  end
  
  #Base initialization for both methods, sets up a connection, and throws
  #an arguement error if the required param is missing
  def self.init(param)
    raise ArgumentError if param.blank?
    
    AWS::S3::Base.establish_connection!(
      :access_key_id => AMAZON_ACCESS_KEY_ID,
      :secret_access_key => AMAZON_SECRET_ACCESS_KEY)
  
  end
end
