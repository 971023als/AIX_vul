#!/usr/bin/python3
import json
import subprocess

def check_log_review_and_reporting_aix():
    results = {
        "분류": "로그 관리",
        "코드": "U-43",
        "위험도": "상",
        "진단 항목": "로그의 정기적 검토 및 보고 (AIX)",
        "진단 결과": "양호",
        "현황": [],
        "대응방안": "보안 로그, 응용 프로그램 및 시스템 로그 기록의 정기적 검토, 분석, 리포트 작성 및 보고 조치 실행"
    }

    log_files = {
        "UTMP": "/var/adm/utmp",
        "WTMP": "/var/adm/wtmp",
        "SULOG": "/var/adm/sulog",
        "ERRPT": "errpt"  # 'errpt' is a command in AIX for error reporting
    }

    for log_name, log_path in log_files.items():
        if log_name == "ERRPT":
            # Checking for errpt entries, indicating the command should be run to view them
            errpt_output = subprocess.run(["errpt"], capture_output=True, text=True)
            if errpt_output.stdout:
                results["현황"].append({"파일명": log_name, "결과": "존재함"})
            else:
                results["현황"].append({"파일명": log_name, "결과": "오류/없음"})
        else:
            if check_file_existence(log_path):
                results["현황"].append({"파일명": log_name, "결과": "존재함"})
            else:
                results["현황"].append({"파일명": log_name, "결과": "존재하지 않음"})

    return results

def check_file_existence(file_path):
    # Direct file existence check for non-command entries
    return os.path.exists(file_path)

def main():
    results = check_log_review_and_reporting_aix()
    print(json.dumps(results, ensure_ascii=False, indent=4))

if __name__ == "__main__":
    main()
