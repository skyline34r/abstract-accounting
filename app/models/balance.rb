class Balance < State
  validates :value, :uniqueness => true
end
