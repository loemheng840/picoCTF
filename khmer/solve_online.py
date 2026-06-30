#!/usr/bin/env python3
"""
Solution using SageMathCell API to solve the discrete log problem
"""
import requests
import json
import time
from Crypto.Cipher import AES
import hashlib

# Challenge parameters
p = 129403459552990578380563458675806698255602319995627987262273876063027199999999
f_coeffs = [87455262955769204408909693706467098277950190590892613056321965035180446006909, 12974562908961912291194866717212639606874236186841895510497190838007409517645, 11783716142539985302405554361639449205645147839326353007313482278494373873961, 55538572054380843320095276970494894739360361643073391911629387500799664701622, 124693689608554093001160935345506274464356592648782752624438608741195842443294, 52421364818382902628746436339763596377408277031987489475057857088827865195813, 50724784947260982182351215897978953782056750224573008740629192419901238915128]
G_u = [95640493847532285274015733349271558012724241405617918614689663966283911276425, 1]
G_v = [23400917335266251424562394829509514520732985938931801439527671091919836508525]
Q_u = [34277069903919260496311859860543966319397387795368332332841962946806971944007, 343503204040841221074922908076232301549085995886639625441980830955087919004, 1]
Q_v = [102912018107558878490777762211244852581725648344091143891953689351031146217393, 65726604025436600725921245450121844689064814125373504369631968173219177046384]
enc_flag = "f9d31f988581d7f9f06239bf26513851d32e73e7ca713aae437ce2e7419a46"

# Create SageMath code
sage_code = f"""
p = {p}
f_coeffs = {f_coeffs}
G_u = {G_u}
G_v = {G_v}
Q_u = {Q_u}
Q_v = {Q_v}

F = GF(p)
R.<x> = PolynomialRing(F)
f = sum(F(f_coeffs[i]) * x^i for i in range(len(f_coeffs)))
H = HyperellipticCurve(f)
J = H.jacobian()

G = J(G_u, G_v)
Q = J(Q_u, Q_v)

print("Jacobian order:", J.order())
print("Solving discrete log...")
k = discrete_log(Q, G, operation='+')
print("k =", k)
"""

print("Sending request to SageMathCell...")
print("(This may take a while...)")

try:
    # Use SageMathCell API
    response = requests.post(
        'https://sagecell.sagemath.org/service',
        data={'code': sage_code},
        timeout=120
    )
    
    if response.status_code == 200:
        result = response.json()
        output = result.get('stdout', '')
        print("SageMath output:")
        print(output)
        
        # Extract k from output
        for line in output.split('\n'):
            if 'k =' in line:
                k = int(line.split('=')[1].strip())
                print(f"\nFound k = {k}")
                
                # Decrypt flag
                key = str(k).encode()
                aes_key = hashlib.sha256(key).digest()[:16]
                cipher_bytes = bytes.fromhex(enc_flag)
                cipher = AES.new(aes_key, AES.MODE_ECB)
                flag = cipher.decrypt(cipher_bytes)
                print(f"Decrypted flag: {flag}")
                break
    else:
        print(f"Error: HTTP {response.status_code}")
        print(response.text)
except Exception as e:
    print(f"Error: {e}")
    print("\nAlternative: Use online SageMath at https://sagecell.sagemath.org/")
    print("Paste the SageMath code and run it there.")
    print("\nSageMath code:")
    print(sage_code)
