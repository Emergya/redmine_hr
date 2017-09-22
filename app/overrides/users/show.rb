Deface::Override.new :virtual_path  => 'users/show',
                     :name          => 'add_user_profile',
                     :original		=> '',                 
                     :insert_after => "erb[silent]:contains(\"unless @user.last_login_on.nil?\")",
                     :text          => "<% unless @user.current_profile.nil? %><li><%=l(:'hr.label_profile')%>: <%= @user.current_profile.name %></li><% else %><li><%=l(:'hr.label_profile')%>: -</li><% end %>"                     