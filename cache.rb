require 'tmpdir'
require 'time'

class Cache

  TMP_DIR = Dir::tmpdir

  def self.get(key, options={}, &block)    
    key = key.gsub /[\/%:?=&]/, ''
    path = File.join(TMP_DIR, "cache.#{key}")
    if File.exists?(path) && !expired?(path, options[:expire])
      File.read(path)
    else
      content = yield
      File.open(path, "w") { |file| file.write content }
      content
    end
  end
  
  def self.expired?(path, expiration_seconds)
    return true  if !File.exists?(path)
    return false if expiration_seconds.nil? || expiration_seconds.zero?
    return File.mtime(path) + expiration_seconds < Time.now
  end

end

  