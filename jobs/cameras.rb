require 'net/http'
 
@cameraDelay = 1 # Needed for image sync. 
@fetchNewImageEvery = '5s'

@camera1Host = "192.168.110.153"  ## CHANGE
@camera1Port = "80"  ## CHANGE
@camera1Username = "None" ## CHANGE
@camera1Password = "" ## CHANGE
@camera1URL = "/cgi/jpg/image.cgi"
@newFile1 = "assets/images/cameras/snapshot1_new.cgi"
@oldFile1 = "assets/images/cameras/snapshot1_old.cgi"

def fetch_image(host,old_file,new_file, cam_port, cam_user, cam_pass, cam_url)
	`rm #{old_file}` 
	`mv #{new_file} #{old_file}`	
	Net::HTTP.start(host,cam_port) do |http|
		req = Net::HTTP::Get.new(cam_url)
		if cam_user != "None" ## if username for any particular camera is set to 'None' then assume auth not required.
			req.basic_auth cam_user, cam_pass
		end
		response = http.request(req)
		open(new_file, "wb") do |file|
			file.write(response.body)
		end
	end
	new_file
end
 
def make_web_friendly(file)
  "/" + File.basename(File.dirname(file)) + "/" + File.basename(file)
end
 
SCHEDULER.every @fetchNewImageEvery, first_in: 0 do
	new_file1 = fetch_image(@camera1Host,@oldFile1,@newFile1,@camera1Port,@camera1Username,@camera1Password,@camera1URL)

	if not File.exists?(@newFile1)
		warn "Failed to Get Camera Image"
	end
 
	send_event('camera1', image: make_web_friendly(@oldFile1))
	sleep(@cameraDelay)
	send_event('camera1', image: make_web_friendly(new_file1))
end
