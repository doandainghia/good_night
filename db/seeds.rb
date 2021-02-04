10.times.each_with_index do |index|
  user = User.create name: "user #{ index.next }"
end
