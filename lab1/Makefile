part1:
	gnatmake part1/scheduler -o part1/scheduler
	make quickClean
	part1/./scheduler

part2:
	gnatmake part2/watchdog -o part2/watchdog
	make quickClean
	part2/./watchdog

part3:
	gnatmake part3/fifo -o part3/fifo
	make quickClean
	part3/./fifo

part4:
	gnatmake part4/fifo_protected -o part4/fifo_protected
	make quickClean
	part4/./fifo_protected

.PHONY: part1 part2 part3 part4

quickClean:
	-rm -rf *.ali
	-rm -rf *.o
clean:
	make quickClean
	-rm -rf */*.ali
	-rm -rf */*.o
	-rm -rf part1/scheduler
	-rm -rf part2/watchdog
	-rm -rf part3/fifo
	-rm -rf part4/fifo_protected
