from sage.all import *
encrypted_flag = [19, 16, 17, 11, 9, 21, 18,
                  2, 3, 22, 7, 4, 25, 21, 5,
                  7, 23, 6, 23, 5, 13, 3, 5,
                  9, 16, 12, 22, 14, 3, 14, 12,
                  22, 18, 4, 3, 9, 2, 19, 5,
                  16, 7, 20, 1, 11, 18, 23, 4,
                  15, 20, 5, 24, 9, 1, 12, 5,
                  16, 10, 7, 2, 1, 21, 1, 25,
                  18, 22, 2, 2, 7, 25, 15, 7, 10]



complete_plaintext = [4, 15, 11, 0, 13, 4, 19, 19, 19]

c = matrix(Zmod(26), [encrypted_flag[i: i + 3] for i in range(0, len(encrypted_flag[:9]), 3)]).transpose()
p = matrix(Zmod(26), [complete_plaintext[i: i + 3] for i in range(0, len(complete_plaintext), 3)]).transpose()


key_matrix = p.solve_left(c)

c = [encrypted_flag[9:][i: i + 3] for i in range(0, len(encrypted_flag[9:]), 3)]

data1 = []
for i in c:
    # get triple of complete_plaintext and tolist
    triple = list(key_matrix.solve_right(vector(i))) 
    data1 += triple
print(data1)
print(list(key_matrix))

# var_list = 'a11,a12,a13,a21,a22,a23,a31,a32,a33'
# a11, a12, a13, a21, a22, a23, a31, a32, a33 = var(var_list)

# res = solve_mod([
#     ((a11 * complete_plaintext[0]) + (a12 * complete_plaintext[1]) + (a13 * complete_plaintext[2])) == encrypted_flag[0],
#     ((a21 * complete_plaintext[0]) + (a22 * complete_plaintext[1]) + (a23 * complete_plaintext[2])) == encrypted_flag[1],
#     ((a31 * complete_plaintext[0]) + (a32 * complete_plaintext[1]) + (a33 * complete_plaintext[2])) == encrypted_flag[2],

#     ((a11 * complete_plaintext[3]) + (a12 * complete_plaintext[4]) + (a13 * complete_plaintext[5])) == encrypted_flag[3],
#     ((a21 * complete_plaintext[3]) + (a22 * complete_plaintext[4]) + (a23 * complete_plaintext[5])) == encrypted_flag[4],
#     ((a31 * complete_plaintext[3]) + (a32 * complete_plaintext[4]) + (a33 * complete_plaintext[5])) == encrypted_flag[5],

#     ((a11 * complete_plaintext[6]) + (a12 * complete_plaintext[7]) + (a13 * complete_plaintext[8])) == encrypted_flag[6],
#     ((a21 * complete_plaintext[6]) + (a22 * complete_plaintext[7]) + (a23 * complete_plaintext[8])) == encrypted_flag[7],
#     ((a31 * complete_plaintext[6]) + (a32 * complete_plaintext[7]) + (a33 * complete_plaintext[8])) == encrypted_flag[8]
# ], 26)
# print(res)