json.users @users do |user|
  json.extract! user, :id, :name, :image, :email, :user_role_id, :lines_edited
end
json.roles @user_roles do |role|
  json.extract! role, :id, :name, :description
end
