class JawboneUpReport < Report
  field :steps, type: Integer
  field :moves_data, type: Hash

  field :sleep, type: Integer
  field :sleeps_data, type: Hash
end
