# Login/Logout
resources(:sessions)
login('/login',   :controller => 'sessions', :action => 'new')
logout('/logout', :controller => 'sessions', :action => 'destroy')

# Account Activation
resources(:activations, :collection => {:deliver => :any})
