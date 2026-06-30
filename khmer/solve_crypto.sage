# Genus 2 Hyperelliptic Curve Challenge
p = 129403459552990578380563458675806698255602319995627987262273876063027199999999
f_coeffs = [87455262955769204408909693706467098277950190590892613056321965035180446006909, 12974562908961912291194866717212639606874236186841895510497190838007409517645, 11783716142539985302405554361639449205645147839326353007313482278494373873961, 55538572054380843320095276970494894739360361643073391911629387500799664701622, 124693689608554093001160935345506274464356592648782752624438608741195842443294, 52421364818382902628746436339763596377408277031987489475057857088827865195813, 50724784947260982182351215897978953782056750224573008740629192419901238915128]

# Define the finite field
F = GF(p)

# Define the polynomial ring
R.<x> = PolynomialRing(F)

# Create the hyperelliptic curve
f = sum(F(f_coeffs[i]) * x^i for i in range(len(f_coeffs)))
H = HyperellipticCurve(f)

# Create Jacobian
J = H.jacobian()

print("Curve created successfully")

# Try different interpretations of the Mumford coordinates
# Format 1: Direct polynomial from coefficients (little-endian)
try:
    G_u_poly = R([95640493847532285274015733349271558012724241405617918614689663966283911276425, 1])
    G_v_poly = R([23400917335266251424562394829509514520732985938931801439527671091919836508525])
    G = J([G_u_poly, G_v_poly])
    print(f"G created successfully: {G}")
except Exception as e:
    print(f"Error creating G (format 1): {e}")
    
# Format 2: Q looks like it works
try:
    Q_u_poly = R([34277069903919260496311859860543966319397387795368332332841962946806971944007, 
                   343503204040841221074922908076232301549085995886639625441980830955087919004, 1])
    Q_v_poly = R([102912018107558878490777762211244852581725648344091143891953689351031146217393, 
                   65726604025436600725921245450121844689064814125373504369631968173219177046384])
    Q = J([Q_u_poly, Q_v_poly])
    print(f"Q created successfully: {Q}")
except Exception as e:
    print(f"Error creating Q: {e}")

# If G doesn't work, maybe it's the generator at infinity or needs different format
# Try finding G differently
if 'G' not in locals():
    print("Trying to find valid G...")
    # Maybe G_u and G_v are actually affine curve points, not Mumford?
    # Let's try converting from affine points
    try:
        # Get curve in affine form and try points
        x_coord = F(95640493847532285274015733349271558012724241405617918614689663966283911276425)
        y_coord = F(23400917335266251424562394829509514520732985938931801439527671091919836508525)
        
        # Check if it's on the curve: y^2 = f(x)
        if y_coord^2 == f(x_coord):
            print(f"Point is on curve!")
            # Convert affine point to Jacobian divisor
            # For a single point P = (x0, y0), Mumford form is u(x) = x - x0, v(x) = y0
            G_u_poly = x - x_coord
            G_v_poly = R(y_coord)
            G = J([G_u_poly, G_v_poly])
            print(f"G from affine point: {G}")
        else:
            print(f"Point NOT on curve. y^2 = {y_coord^2}, f(x) = {f(x_coord)}")
    except Exception as e:
        print(f"Error in affine conversion: {e}")

# Attempt discrete log
if 'G' in locals() and 'Q' in locals():
    print("\nAttempting discrete log Q = k*G...")
    try:
        k = discrete_log(Q, G, operation='+')
        print(f"\n*** SUCCESS! Found k = {k} ***")
        
        # Save k to file for Python to read
        import os
        with open('/tmp/sage_result.txt', 'w') as f:
            f.write(str(k))
        print("Result saved to /tmp/sage_result.txt")
    except Exception as e:
        print(f"Error in discrete log: {e}")
        import traceback
        traceback.print_exc()
else:
    print("\nCould not create both G and Q properly")
