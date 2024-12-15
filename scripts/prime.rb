def isprime(n)
    if(n <= 1) then
      return false
    end
    for i in (2..n-1) do
      if(n%i == 0) then 
        return false
      end
    end
    return true
end


$primes = Array.new


for i in 1 .. 20000 do
  if(isprime(i)) then 
    $primes.push(i)
  end
end

puts $primes
