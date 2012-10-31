require 'rubygems'
require 'sinatra'
require "google_drive"
require 'digest'
require 'json'
require 'fileutils'
require 'logger'

set :port, 4568

Dir.mkdir('logs') unless File.exist?('logs')
$log = Logger.new('logs/output.log')

configure do
    $log.level = Logger::DEBUG
end

post '/gdriveFiles' do
	request.body.rewind  # in case someone already read it
	content_type :json;
	data = JSON.parse request.body.read
	
	$log.debug 'folder requested: '+data['folderName'];
	
	session = GoogleDrive.login("intermedia.miracle@gmail.com", "vaffel123");
	#this queries the folder called 'heatpump'
	@folderHierarchy = session.collection_by_url('https://docs.google.com/feeds/default/private/full/folder%3A0B0ISH1Jh_26pSE1tdjE2RWlhM0E?v=3');
	
	#$log.debug @folderHierarchy.files;
	
	fileURLs = [];
	
	for file in @folderHierarchy.files
		if file.title.include?(data['folderName'])
			@requestedFolder = session.collection_by_url(file.document_feed_url);
		
			for file in @requestedFolder.files
				fileURLs.push({:title => file.title, :url => file.human_url()});
			end
		end
	end
	
	return fileURLs.to_json;
	
end