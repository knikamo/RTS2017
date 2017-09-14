with ada.text_IO; use ada.text_IO;
with ada.calendar; use ada.calendar;
with ada.numerics.discrete_random;

procedure fifo_protected is

-- Protected Buffer ************************************ --
  type buffer_array is array(0 .. 9) of integer;

  protected buffer is
    entry insert_number(number : in integer);
    entry get_number(number : out integer);
    private
    fifo_buffer : buffer_array;
    Number_of_elements : integer := 0;
  end buffer;

  protected body buffer is

    entry insert_number(number : in integer) when Number_of_elements < 10 is
    begin
      fifo_buffer(1 .. Number_of_elements) := fifo_buffer(0 .. Number_of_elements - 1);
      fifo_buffer(0) := number;
      Number_of_elements := Number_of_elements + 1;
    end insert_number;

    entry get_number(number : out integer) when Number_of_elements > 0 is
    begin
      number := fifo_buffer(Number_of_elements-1);
      Number_of_elements := Number_of_elements - 1;
    end get_number;
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
        generated_number := random(G);
        Time_to_next := duration(float(generated_number)*0.04);
        select
          accept stop(bool : in boolean) do
            Should_stop_Producer := true;
            put_line("Task Producer was terminated");
          end stop;
        or
          delay until clock + Time_to_next;
          buffer.insert_number(generated_number);
          put_line("Produced: "& integer'image(generated_number));
        end select;
      end loop;
    end producer;

-- Consumer ****************************************** --
  Task Consumer is
  end consumer;

  task body consumer is
    recieved_number : integer;
    total_sum : integer :=0;
    generated_number : integer;
    subtype Put_values is integer range 0 .. 25;
    package Random_int is new Ada.numerics.discrete_random (Put_values);
    use Random_int;
    G : Generator;
    Time_to_next : duration;

    begin while total_sum < 100 loop
      reset(G);
      generated_number := random(G);
      Time_to_next := duration(float(generated_number)*0.04);
      buffer.get_number(recieved_number);
      put_line("Consumed: "& integer'image(recieved_number));
      total_sum := total_sum + recieved_number;
      put_line("    * Total sum is "& integer'image(total_sum));
      delay until clock + Time_to_next;

    end loop;
    producer.stop(true);
    put_line("Total sum is over 100");

  end consumer;

begin
  null;
end fifo_protected;
