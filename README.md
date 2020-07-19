# starmn 

- First I ran 'VideoToFrame.m' to convert video into frames (single run does the job for all folders)

- Then I ran 'BorderOnImg' to put boxes on original locations of drones (single run does the job for all folders)

- 'MainCode.m' is ran in 30 given folders with YOLOv3 outputs. (30 runs for 30 folders)

- MN = 1; if M/N=1(0) do(don't do) elimination due to M/N

- CC = 1; if CC=1(0) do(don't do) cross correlation
