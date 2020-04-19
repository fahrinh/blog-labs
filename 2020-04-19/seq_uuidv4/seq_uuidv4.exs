defmodule SeqUUIDv4 do
  def generate() do
    unix_time = DateTime.utc_now() |> DateTime.to_unix()

    <<_r0::32, r1::16, _r2::4, r3::12, _r4::2, r5::62>> = :crypto.strong_rand_bytes(16)
    <<unix_time::32, r1::16, 4::4, r3::12, 2::2, r5::62>>
  end
end

# id = SeqUUIDv4.generate()
# id |> IO.inspect()

# <<idnum::128>> = id
# idnum |> IO.inspect()

# <<backtime::32, _::96>> = id
# backtime |> IO.inspect()

# Base.encode16(id) |> IO.puts()
