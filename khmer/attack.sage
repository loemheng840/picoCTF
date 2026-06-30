# Attack using the fact that f(x) factors
p = 129403459552990578380563458675806698255602319995627987262273876063027199999999
f_coeffs = [87455262955769204408909693706467098277950190590892613056321965035180446006909, 12974562908961912291194866717212639606874236186841895510497190838007409517645, 11783716142539985302405554361639449205645147839326353007313482278494373873961, 55538572054380843320095276970494894739360361643073391911629387500799664701622, 124693689608554093001160935345506274464356592648782752624438608741195842443294, 52421364818382902628746436339763596377408277031987489475057857088827865195813, 50724784947260982182351215897978953782056750224573008740629192419901238915128]

F = GF(p)
R.<x> = PolynomialRing(F)
f = sum(F(f_coeffs[i]) * x^i for i in range(len(f_coeffs)))
H = HyperellipticCurve(f)
J = H.jacobian()

G_u_poly = R([95640493847532285274015733349271558012724241405617918614689663966283911276425, 1])
G_v_poly = R([23400917335266251424562394829509514520732985938931801439527671091919836508525])
G = J([G_u_poly, G_v_poly])

Q_u_poly = R([34277069903919260496311859860543966319397387795368332332841962946806971944007, 
               343503204040841221074922908076232301549085995886639625441980830955087919004, 1])
Q_v_poly = R([102912018107558878490777762211244852581725648344091143891953689351031146217393, 
               65726604025436600725921245450121844689064814125373504369631968173219177046384])
Q = J([Q_u_poly, Q_v_poly])

print("[+] Curve and points created")
print(f"[+] f(x) factors completely - this enables attacks!")

# Try with larger bounds
bounds_to_try = [2^35, 2^40, 2^45]

for bound in bounds_to_try:
    print(f"\n[*] Trying BSGS with bound = 2^{bound.nbits()-1} ≈ {bound}")
    try:
        from sage.groups.generic import bsgs
        k = bsgs(G, Q, bounds=(0, bound), operation='+')
        print(f"\n[!!!] SUCCESS! k = {k}")
        with open('/tmp/sage_result.txt', 'w') as f:
            f.write(str(k))
        break
    except ValueError as e:
        if "does not exist" in str(e):
            print(f"[-] k not in range [0, {bound}]")
            continue
        else:
            print(f"[-] Error: {e}")
            break
    except Exception as e:
        print(f"[-] Error: {e}")
        break

print("\n[*] If BSGS failed, trying Pollard rho...")
try:
    k = discrete_log(Q, G, operation='+', ord=None)
    print(f"\n[!!!] SUCCESS! k = {k}")
    with open('/tmp/sage_result.txt', 'w') as f:
        f.write(str(k))
except Exception as e:
    print(f"[-] Pollard rho failed: {e}")
