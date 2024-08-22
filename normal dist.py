import random
import matplotlib.pyplot as plt
import numpy as np
sum = False # True for sum, False for mean
sample_size = 5
number_of_samples = 20000 # Number of samples of size <sample_size>
dice_faces = 20
data = []
normalized_data = []
for i in range(0, number_of_samples):
    sample = []
    for j in range(0, sample_size):
        roll = random.randint(1, dice_faces)
        data.append(roll)
        sample.append(roll)
    if sum:
        normalized_data.append(np.sum(sample))
    else:
        normalized_data.append(np.mean(sample))

print(len(data))
print(len(normalized_data))

fig = plt.figure()
ax1 = fig.add_subplot(221)
n, bins, patches = ax1.hist(data, bins=dice_faces, cumulative=0)
ax1.set_xlabel('Roll results', size=10)
ax1.set_ylabel('Frequency (number of rolls)', size=10)
ax1.set_xbound(1, dice_faces)
ax1.legend
ax1.title.set_text('Frequency of each\ndice roll result')

ax2 = fig.add_subplot(222)
n, bins, patches = ax2.hist(normalized_data, bins=dice_faces*(sample_size if sum else 1), cumulative=0)
ax2.set_xlabel('Sample ' + str('sums' if sum else 'means'), size=10)
ax2.set_xbound(1, sample_size*dice_faces if sum else dice_faces)
ax1.set_ylabel('Frequency (number of occurrences)', size=10)
ax2.legend
ax2.title.set_text('Probability density\nof a dice roll')
fig.tight_layout()
plt.show()