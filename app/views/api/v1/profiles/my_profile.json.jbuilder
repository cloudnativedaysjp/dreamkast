json.id(@profile.id)
json.email(@profile.email)
json.name("#{@profile.last_name} #{@profile.first_name}")
json.isAttendOffline(@profile.attend_offline?)
