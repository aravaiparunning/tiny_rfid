def thing_as_bytes(bytes)
  case bytes
  when Numeric then [bytes]
  when String then bytes.bytes
  when Array then bytes
  else bytes
  end
end