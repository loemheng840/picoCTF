import subprocess

pos_pw_list = ["8799", "d3ab", "1ea2", "acaf", "2295", "a9de", "6f3d"]

for pw in pos_pw_list:
    print(f"Trying: {pw}")
    result = subprocess.run(
        ["python", "cracking", "level3.py", "-e", "level3.flag.txt.enc"],
        input=pw,
        capture_output=True,
        text=True
    )
    if "flag" in result.stdout.lower():
        print(f"FOUND! Password: {pw}")
        print(result.stdout)
        break