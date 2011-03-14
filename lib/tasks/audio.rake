namespace :audio do  
  task :convert =>  :environment do
    Child.all.select {|x| x.audio && x.audio.content_type == "audio/amr" }.each do |child| 
      data = child.audio.data
      amr_file = "/Users/admin/test.amr"
      ogg_file = "/Users/admin/test.ogg"
      temporary_out_file = File.new(amr_file, 'w')
      temporary_out_file.write(data.read)
      temporary_out_file.close
    
      %x[ ffmpeg -y -i #{amr_file} #{ogg_file} ]
      
      temporary_in_file = File.new(ogg_file, 'r')
      in_file_attachment = FileAttachment.new child.audio.name, "audio/ogg", temporary_in_file.read      
      child.delete_attachment 'recorded_audio'
      
      child.attach(in_file_attachment, 'recorded_audio')
      
      # child.married = true
      temporary_in_file.close
      
      child.save!
      p child
      p in_file_attachment
      p child.audio
      
    end
    
  end
end