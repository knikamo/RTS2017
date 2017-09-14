with ada.text_IO; use ada.text_IO;
with ada.calendar; use ada.calendar;
with ada.numerics.discrete_random;

procedure Fifo is

  -- Buffer ****************************************** --
  Task Buffer is
    entry insert_number(number : in integer);
    entry get_number(number : out integer);
    entry stop(bool : in boolean);
  end buffer;

  Task body buffer is
    fifo_buffer : array (0 .. 9) of integer;
    Number_of_elements : integer := 0;
    Should_stop_buffer : boolean := false;
  begin
    while not Should_stop_buffer loop
      select
        when Number_of_elements < 10 =>
          accept insert_number(number : in integer) do
            -- move all elements one step
            fifo_buffer(1 .. Number_of_elements) := fifo_buffer(0 .. Number_of_elements - 1);
            -- insert the new number first in the buffer
            fifo_buffer(0) := number;
            Number_of_elements := Number_of_elements + 1;
          end insert_number;
      or
        when Number_of_elements > 0 =>
          accept get_number(number : out integer) do
            -- get the last element in the buffer
            number := fifo_buffer(Number_of_elements-1);
            Number_of_elements := Number_of_elements - 1;
          end get_number;
      or
        accept stop(bool : in boolean) do
          Should_stop_buffer := bool;
          put_line("Task Buffer is terminated");

        end stop;
      end select;
    end loop;
  end buffer;

  -- Producer ****************************************** --
  Task Producer is
    entry stop(bool : in boolean);
  end Producer;

  task body Producer is
    Should_stop_Producer : boolean := false;
    generated_number : integer;
    subtype Put_values is integer range 0 .. 25;
    package Random_int is new Ada.numerics.discrete_random (Put_values);
    use Random_int;
    G : Generator;
    Time_to_next : duration;

    begin
      while not Should_stop_Producer loop
        reset(G);
        generated_number := random(G); -- generate a number betweeen 0-25
        -- due to laziness we also use the same random number to calcualte a delay time betweeen 0-1
        Time_to_next := duration(float(generated_number)*0.04);
        select
          delay until clock + Time_to_next;
          buffer.insert_number(generated_number);
          put_line("Produced: " & integer'image(generated_number));
        or
          accept stop(bool : in boolean) do
            Should_stop_Producer := true;
            put_line("Task Producer was terminated");
          end stop;
        end select;
      end loop;
    end producer;


  -- Consumer ****************************************** --
  Task Consumer is
  end consumer;

  task body consumer is
    recieved_number : integer;
    total_sum : integer := 0;
    generated_number : integer;
    subtype Put_values is integer range 0 .. 25;
    package Random_int is new Ada.numerics.discrete_random (Put_values);
    use Random_int;
    G : Generator;
    Time_to_next : duration;

    begin
      while total_sum < 100 loop
        reset(G);
        generated_number := random(G);
        Time_to_next := duration(float(generated_number)*0.04);
        delay until clock + Time_to_next;
        -- consume a number
        buffer.get_number(recieved_number);
        put_line("Consumed: "& integer'image(recieved_number));
        total_sum := total_sum + recieved_number;
        put_line("    * Total sum is "& integer'image(total_sum));
      end loop;

      buffer.stop(true);
      producer.stop(true);
      put_line("Total sum is over 100");
  end consumer;

begin
  null;
end Fifo;
