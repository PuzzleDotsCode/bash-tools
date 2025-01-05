import subprocess
import time

# Your IPinfo token
IPINFO_TOKEN = "766d03a697bc51"

# Function to check if a host is up
def check_host(ip):
    try:
        # Run the ping command
        output = subprocess.run(
            ["ping", "-c", "1", "-W", "1", str(ip)],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        if output.returncode == 0:  # Host is up
            return True  # Indicate that the host is up
    except Exception as e:
        print(f"        ! Error checking {ip}: {str(e)}")
    return False  # Host is down

# Function to get IP information using ipinfo with token
def get_ip_info(ip):
    try:
        # Run the ipinfo command with the token
        ipinfo_output = subprocess.run(
            ["ipinfo", ip, "--token", IPINFO_TOKEN],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        return ipinfo_output.stdout.strip()  # Return the output from ipinfo
    except Exception as e:
        return f"        ! Error fetching info for {ip}: {str(e)}"

# Main script execution
if __name__ == "__main__":
    # Loop through IP ranges
    for one in range(1,256):
        print(f"[*] Testing: {one}.x.x.x")
        for two in range(256):
            print(f"    + {one}.{two}.x.x")
            for three in range(256):
                print(f"      - {one}.{two}.{three}.x")
                for four in range(256):
                    ip = f"{one}.{two}.{three}.{four}"
                    print(f"        Testing IP: {ip}", end="\r")  # Update the current IP on the same line
                    if check_host(ip):  # Check if the host is up
                        print(f"\n        + Host is up {ip}")
                        ip_info = get_ip_info(ip)  # Get information for the IP
                        print(f"        Info: {ip_info}")
                    time.sleep(0.01)  # Slight delay to make output readable

    print("\nScanning complete.")
