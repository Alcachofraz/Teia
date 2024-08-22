from functools import cmp_to_key

def compare(item1, item2):
    return item1[1] - item2[1]

text = 'How much wood could a woodchuck chuck if a woodchuck could chuck wood'
V = 20
vocab = []

# Get word frequencies
# $corpus is a dictionary where the key is a word and the vlaue is its frequency
# Throughout iterations, these words will be split into a list of subwords
words = text.split(" ")
words = [" ".join(word) for word in words]
corpus = {}
for word in words:
    if (word not in corpus):
        corpus[word] = 1
    else:
        corpus[word] += 1
        
print("Initial Corpus:")
print(corpus)

# Add basic vocabulary (characters)
for i in range(0, len(text)):
    if (text[i] not in vocab and text[i] != " "):
        vocab.append(text[i])

print("Initial Vocabulary:")
print(vocab)

# Run BPE
while len(vocab) < V:
    # Search for best pair
    pairs = {}
    for word, freq in corpus.items():
        symbols = word.split(" ")
        for i in range(len(symbols) - 1):
            pair = (symbols[i], symbols[i+1])
            if pair in pairs:
                pairs[pair] += freq
            else:
                pairs[pair] = 1
    best_pair = max(pairs, key=pairs.get)
    # Replace in corpus
    old = ' '.join(best_pair)
    new = ''.join(best_pair)
    new_corpus = {}
    for word in corpus:
        new_word = word.replace(old, new)
        new_corpus[new_word] = corpus[word]
    corpus = new_corpus
    # Add to vocabulary  
    vocab.append(new)
        
print("Final Corpus:")
print(corpus)

print("Final Vocabulary:")
print(vocab)


