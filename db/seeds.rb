# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts "Cleaning up database..."
User.destroy_all
Role.destroy_all
Task.destroy_all if defined?(Task)
Project.destroy_all if defined?(Project)
Comment.destroy_all if defined?(Comment)

puts "Creating system admin..."
admin_role = Role.find_or_create_by!(name: 'system_admin') do |r|
  r.description = 'System Administrator'
end

User.find_or_create_by!(email: 'admin@system.com') do |user|
  user.password = 'password'
  user.password_confirmation = 'password'
  user.role = admin_role
end
puts "System admin created successfully!"
