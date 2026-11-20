require 'webrick'

root = File.expand_path(File.dirname(__FILE__))
server = WEBrick::HTTPServer.new(
  Port: 3000,
  BindAddress: '0.0.0.0',
  Logger: WEBrick::Log.new($stderr, WEBrick::Log::INFO),
  AccessLog: [[$stderr, WEBrick::AccessLog::COMBINED_LOG_FORMAT]]
)

server.mount_proc '/' do |req, res|
  path = req.path == '/' ? '/index.html' : req.path
  file = File.join(root, path)
  if File.file?(file)
    if path.end_with?('.html')
      res['Content-Type'] = 'text/html; charset=utf-8'
    elsif path.end_with?('.css')
      res['Content-Type'] = 'text/css; charset=utf-8'
    elsif path.end_with?('.js')
      res['Content-Type'] = 'application/javascript; charset=utf-8'
    elsif path.end_with?('.jpg') || path.end_with?('.jpeg')
      res['Content-Type'] = 'image/jpeg'
    elsif path.end_with?('.png')
      res['Content-Type'] = 'image/png'
    elsif path.end_with?('.webp')
      res['Content-Type'] = 'image/webp'
    else
      res['Content-Type'] = 'application/octet-stream'
    end
    # Reading into a string avoids kernel sendfile/IO.copy_stream Errno::EPERM
    res.body = File.binread(file)
  else
    res.status = 404
    res.body = 'Not Found'
  end
end

trap('INT') { server.shutdown }
trap('TERM') { server.shutdown }
server.start
