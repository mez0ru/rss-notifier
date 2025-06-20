# frozen_string_literal: true

class App
  hash_branch('users') do |r|
    r.post true do
      # @user = User.new(first_name: r.params['first_name'], last_name: r.params['last_name'])
      # @user.save
      # flash[:notice] = "User created"
      r.redirect '/'
    end
  end
end
