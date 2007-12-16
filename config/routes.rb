# Login/Logout
map.resources(:sessions)
map.login('/login',   :controller => 'sessions', :action => 'new')
map.logout('/logout', :controller => 'sessions', :action => 'destroy')
