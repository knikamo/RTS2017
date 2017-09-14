with ada.text_IO; use ada.text_IO;
with ada.calendar; use ada.calendar;

procedure Scheduler is
  Start_time : Time := Clock;
  F1_start : Time := Start_time + duration(1.0);
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
  begin
    put("     F3 executing, time is now: ");
    put_line(Duration'Image(Clock - Start_time));
  end F3;

begin
  loop
    delay until F1_start;
    F1;
    F2;
    if Seconds mod 2 = 0 then -- execute F3 every other second
      delay until F1_start + duration(0.5); -- start executing F3 0.5 seconds ater F1 started
      F3;
    end if;
    Seconds := Seconds + 1;
    F1_start := F1_start + duration(1.0); -- The next F1 period starts 1.0 seconds after the current period.
  end loop;

end Scheduler;
