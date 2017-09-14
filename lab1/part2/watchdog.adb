with ada.text_IO; use ada.text_IO;
with ada.calendar; use ada.calendar;
with ada.numerics.float_random; use ada.numerics.float_random;

procedure Watchdog is
  Start_time : Time := Clock;
  Period_time : Time := Start_time + duration(1.0);
  Seconds : Integer := 0; -- Seconds keeps track of when F3 should execute

  procedure F1 is
  begin
    put("F1 executing, time is now: ");
    put_line(Duration'Image(Clock - Start_time));
  end F1;

  procedure F2 is
  begin
    put("F2 executing, time is now: ");
    put_line(Duration'Image(Clock - Start_time));
  end F2;

  procedure F3 is
    G : Generator; -- to generate random numbers
    rnd_time : uniformly_distributed;
    F3_duration : duration; -- how long time F3 has executed
    Start_time_F3 : Time := Clock;

    Task Watch_dog is
      entry get_duration(F3_duration : out duration);
    end Watch_dog;

    task body Watch_dog is
      Task_start : Time := Start_time_F3; -- the Watchdog has the same start time as F3
    begin

      select
        accept get_duration(F3_duration : out duration) do
          F3_duration := Clock - Task_start;
        end get_duration;
      or
        delay until Task_start + duration(0.5);
        -- print a warning when execution time exceeds 0.5
        put_line("     Warning, F3 still running");
        accept get_duration(F3_duration : out duration) do
          F3_duration := Clock - Task_start;
        end get_duration;
      end select;
    end Watch_dog;

  begin
    reset(G);
    rnd_time := random(G); -- generate a random number between 0-1.
    put("     F3 executing, time is now: ");
    put_line(Duration'Image(Clock - Start_time));
    delay until Start_time_F3 + duration(rnd_time) * 2.0; -- F3 executes for 0-2 seconds.
    Watch_dog.get_duration(F3_duration);

    -- re-synchronize so that F1 starts at whole seconds
    if F3_duration > duration(0.5) then
      Period_time := Period_time + Duration(Float'Rounding(Float(F3_duration)));
      Seconds := 0;
    end if;
  end F3;


begin
  loop
    delay until Period_time;
    F1;
    F2;
    if Seconds mod 2 = 0 then
      delay until Period_time + duration(0.5);
      F3;
    end if;
    Seconds := Seconds + 1;
    Period_time := Period_time + duration(1.0);
  end loop;

end Watchdog;
