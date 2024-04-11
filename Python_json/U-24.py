#!/usr/bin/python3
import subprocess
import json

def check_nfs_services_disabled_aix():
    results = {
        "분류": "서비스 관리",
        "코드": "U-24",
        "위험도": "상",
        "진단 항목": "NFS 서비스 비활성화 (AIX)",
        "진단 결과": "양호",  # Assume services are disabled by default
        "현황": [],
        "대응방안": "불필요한 NFS 서비스 관련 데몬 비활성화"
    }

    # Check SRC for NFS-related services
    nfs_services = subprocess.run(['lssrc', '-g', 'nfs'], stdout=subprocess.PIPE, text=True).stdout
    if "active" in nfs_services:
        results["진단 결과"] = "취약"
        results["현황"].append("NFS 서비스 관련 데몬이 SRC를 통해 실행 중입니다.")
    elif process.returncode == 1:
        results["진단 결과"] = "양호"
        results["현황"].append("NFS 서비스 관련 데몬이 비활성화되어 있습니다.")
    else:
        # subprocess 실행 중 오류 처리
        results["진단 결과"] = "오류"
        results["현황"].append(f"서비스 확인 중 오류 발생: {process.stderr}")

    return results

def main():
    results = check_nfs_services_disabled_aix()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()
