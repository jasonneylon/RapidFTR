require 'tmpdir'

namespace :audio do  
  task :convert =>  :environment do
    Child.all.select {|x| x.audio && x.audio.content_type == "audio/amr" }.each do |child| 
      data = child.audio.data

      amr_file_path = File.join(Dir.tmpdir, "rapidftr.amr")
      mp3_file_path = File.join(Dir.tmpdir, "rapidftr.mp3")
      
      File.open(amr_file_path, 'w') {|amr_file| amr_file.write(data.read)}
    
      convert amr_file_path, mp3_file_path
      
      mp3_attachment = create_mp3_attachment(mp3_file_path)
      child.attach(mp3_attachment, 'recorded_audio_mp3')
      child.save!      
    end
    
  end
end

def convert(amr_file_path, mp3_file_path)
  %x[ ffmpeg -y -i #{amr_file_path} #{mp3_file_path} ]
end

def create_mp3_attachment(mp3_file_path)
  File.open(mp3_file_path, 'r') do |mp3_file|
    FileAttachment.from_file mp3_file, "audio/mp3", "audio"
  end
end
