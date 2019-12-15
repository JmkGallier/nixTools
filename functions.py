def min_coins(cents):
    change = cents
    coins_denomination = [25, 10, 5, 1]
    coins = 0

    for i in coins_denomination:
        while i <= change:
            change -= i
            coins += 1

    return coins


def reverse(strMy):
    output = ""
    for i in range(len(strMy)):
        output += strMy[(len(strMy)-1)-i]
        print(output)

    return output


ret = reverse("tallahasee")
print(ret)
