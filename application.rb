require 'rubygems'
require 'sinatra'
require "google_drive"
require 'json'

$KCODE = "UTF-8"





post '/gdriveFiles' do
	request.body.rewind  # in case someone already read it
	content_type :json;
	data = JSON.parse request.body.read
	p data['folderName']
	
	session = GoogleDrive.login(ENV['GOOGLE_LGIN'], ENV['GOOGLE_PASS']);
	@folderHierarchy = session.collection_by_url('https://docs.google.com/feeds/default/private/full/folder%3A0B0ISH1Jh_26pSE1tdjE2RWlhM0E?v=3');
	
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