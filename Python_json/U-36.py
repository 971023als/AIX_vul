#!/usr/bin/python3
import subprocess
import json

def check_web_service_process_permissions_aix():
    results = {
        "분류": "서비스 관리",
        "코드": "U-36",
        "위험도": "상",
        "진단 항목": "웹서비스 웹 프로세스 권한 제한 (AIX)",
        "진단 결과": None,  # 초기 상태 설정, 검사 후 결과에 따라 업데이트
        "현황": [],
        "대응방안": "IBM HTTP Server 데몬 root 권한 구동 방지"
    }

    # Assuming common IBM HTTP Server configuration locations
    config_paths = [
        "/usr/IBM/HTTPServer/conf/httpd.conf",  # Adjust as necessary
    ]
    
    found_vulnerability = False

    for config_path in config_paths:
        if os.path.isfile(config_path):
            with open(config_path, 'r') as file:
                content = file.readlines()
                for line in content:
                    if 'Group' in line and not line.strip().startswith('#'):
                        group_setting = line.split()
                        if len(group_setting) > 1 and group_setting[1].strip().lower() == 'root':
                            results["진단 결과"] = "취약"
                            results["현황"].append(f"{config_path} 파일에서 IBM HTTP Server 데몬이 root 권한으로 구동되도록 설정되어 있습니다.")
                            found_vulnerability = True
                            break
            if found_vulnerability:
                break

    if not found_vulnerability:
        results["진단 결과"] = "양호"
        results["현황"].append("IBM HTTP Server 데몬이 root 권한으로 구동되도록 설정되어 있지 않습니다.")

    return results

def main():
    results = check_web_service_process_permissions_aix()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()
