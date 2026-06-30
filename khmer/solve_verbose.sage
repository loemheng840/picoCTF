# Genus 2 Hyperelliptic Curve Challenge
p = 129403459552990578380563458675806698255602319995627987262273876063027199999999
f_coeffs = [87455262955769204408909693706467098277950190590892613056321965035180446006909, 12974562908961912291194866717212639606874236186841895510497190838007409517645, 11783716142539985302405554361639449205645147839326353007313482278494373873961, 55538572054380843320095276970494894739360361643073391911629387500799664701622, 124693689608554093001160935345506274464356592648782752624438608741195842443294, 52421364818382902628746436339763596377408277031987489475057857088827865195813, 50724784947260982182351215897978953782056750224573008740629192419901238915128]

F = GF(p)
R.<x> = PolynomialRing(F)
f = sum(F(f_coeffs[i]) * x^i for i in range(len(f_coeffs)))
H = HyperellipticCurve(f)
J = H.jacobian()

print("[+] Curve created")

# Create G from affine point
G_u_poly = R([95640493847532285274015733349271558012724241405617918614689663966283911276425, 1])
G_v_poly = R([23400917335266251424562394829509514520732985938931801439527671091919836508525])
G = J([G_u_poly, G_v_poly])
print(f"[+] G = {G}")

# Create Q
Q_u_poly = R([34277069903919260496311859860543966319397387795368332332841962946806971944007, 
               343503204040841221074922908076232301549085995886639625441980830955087919004, 1])
Q_v_poly = R([102912018107558878490777762211244852581725648344091143891953689351031146217393, 
               65726604025436600725921245450121844689064814125373504369631968173219177046384])
Q = J([Q_u_poly, Q_v_poly])
print(f"[+] Q = {Q}")

# Check a few multiples of G to see if Q appears
print("\n[*] Checking small multiples of G...")
for i in range(1, 20):
    if i * G == Q:
        print(f"\n[!!!] FOUND: Q = {i} * G")
        print(f"k = {i}")
        with open('/tmp/sage_result.txt', 'w') as f:
            f.write(str(i))
        import sys
        sys.exit(0)

print("\n[*] Q not in first 20 multiples, computing order...")
try:
    # Try to get order
    order_G = G.order()
    print(f"[+] Order of G: {order_G}")
    print(f"[+] Bits: {order_G.nbits()}")
except Exception as e:
    print(f"[-] Could not compute order: {e}")

print("\n[*] Attempting discrete log (this may take a while)...")
try:
    k = discrete_log(Q, G, operation='+')
    print(f"\n[!!!] SUCCESS: k = {k}")
    with open('/tmp/sage_result.txt', 'w') as f:
        f.write(str(k))
except Exception as e:
    print(f"[-] Discrete log failed: {e}")
    import traceback
    traceback.print_exc()
