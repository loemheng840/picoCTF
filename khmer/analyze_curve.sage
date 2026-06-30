# Analyze the curve for weaknesses
p = 129403459552990578380563458675806698255602319995627987262273876063027199999999
f_coeffs = [87455262955769204408909693706467098277950190590892613056321965035180446006909, 12974562908961912291194866717212639606874236186841895510497190838007409517645, 11783716142539985302405554361639449205645147839326353007313482278494373873961, 55538572054380843320095276970494894739360361643073391911629387500799664701622, 124693689608554093001160935345506274464356592648782752624438608741195842443294, 52421364818382902628746436339763596377408277031987489475057857088827865195813, 50724784947260982182351215897978953782056750224573008740629192419901238915128]

print(f"[*] Prime p = {p}")
print(f"[*] Prime bits: {p.nbits()}")
print(f"[*] Is prime: {is_prime(p)}")

# Check if p is special
print(f"\n[*] Checking for special prime forms...")
print(f"p - 1 = {p - 1}")
print(f"(p - 1) factors (trying)...")

# Try small factors
n = p - 1
small_factors = []
for prime in [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31]:
    count = 0
    while n % prime == 0:
        n = n // prime
        count += 1
    if count > 0:
        small_factors.append((prime, count))
        
print(f"Small factors of (p-1): {small_factors}")

# Check f(x) for special properties
F = GF(p)
R.<x> = PolynomialRing(F)
f = sum(F(f_coeffs[i]) * x^i for i in range(len(f_coeffs)))

print(f"\n[*] Polynomial f(x) degree: {f.degree()}")
print(f"\n[*] Trying to factor f(x) over F_p...")
try:
    factorization = f.factor()
    print(f"f(x) = {factorization}")
    if len(list(factorization)) > 1:
        print("[!!!] f(x) factors! This might be exploitable!")
except Exception as e:
    print(f"Factorization failed or took too long: {e}")

# Create curve and check properties
H = HyperellipticCurve(f)
J = H.jacobian()

print(f"\n[*] Creating points...")
G_u_poly = R([95640493847532285274015733349271558012724241405617918614689663966283911276425, 1])
G_v_poly = R([23400917335266251424562394829509514520732985938931801439527671091919836508525])
G = J([G_u_poly, G_v_poly])

Q_u_poly = R([34277069903919260496311859860543966319397387795368332332841962946806971944007, 
               343503204040841221074922908076232301549085995886639625441980830955087919004, 1])
Q_v_poly = R([102912018107558878490777762211244852581725648344091143891953689351031146217393, 
               65726604025436600725921245450121844689064814125373504369631968173219177046384])
Q = J([Q_u_poly, Q_v_poly])

print("[+] G and Q created")

# Try BabyStep GiantStep with smaller bound
print("\n[*] Trying Baby-step Giant-step with small bound...")
try:
    from sage.groups.generic import bsgs
    # Try with small bound first
    bound = 2^30
    print(f"[*] Trying bound = 2^30 = {bound}")
    k = bsgs(G, Q, bounds=(0, bound), operation='+')
    print(f"\n[!!!] FOUND: k = {k}")
    with open('/tmp/sage_result.txt', 'w') as f:
        f.write(str(k))
except Exception as e:
    print(f"[-] BSGS failed: {e}")

print("\n[*] Done")
