local eachsecond = 0

scriptsetup = function( object )
  object.scriptupdate  = localupdate

  eachsecond = 0
end

 localupdate = function( caller, dt )

  eachsecond = eachsecond + dt

  if ( eachsecond > 1 ) then
    print("EACH SECOND I TALK!")
    eachsecond = 0
  end

end
