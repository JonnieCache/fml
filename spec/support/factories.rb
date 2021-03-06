require 'factory_girl'

FactoryGirl.define do
  to_create(&:save)
  
  factory :task do
    name 'do work'
    description 'do a lot of work'
    recurring false
    value 10
    
    user
  end
  
  factory :completion do
    value 10
    
    task
    user
  end
  
  factory :nomination do
    nominated_for { Date.today }
    # task_order [1,2]
    
    user
  end
  
  factory :user do
    name  { Faker::Name.name }
    email { Faker::Internet.email }
    password 'foobar'
  end
  
  factory :tag
end
