#!/usr/bin/env python3
import json
import re
from datetime import datetime
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from typing import Any, Dict, List


HOST = "127.0.0.1"
PORT = 8080


KNOWN_SKILLS = [
    "Flutter",
    "Dart",
    "Riverpod",
    "Firebase",
    "Supabase",
    "Figma",
    "Product Design",
    "Design Systems",
    "User Research",
    "Prototyping",
    "Python",
    "SQL",
    "Machine Learning",
    "Project Management",
    "React",
    "TypeScript",
]


def _as_list(value: Any) -> List[str]:
    if isinstance(value, list):
        return [str(item).strip() for item in value if str(item).strip()]
    if value is None:
        return []
    text = str(value).strip()
    if not text:
        return []
    return [item.strip() for item in re.split(r",|\n|;", text) if item.strip()]


def _as_text(value: Any, fallback: str = "") -> str:
    if value is None:
        return fallback
    return str(value).strip() or fallback


def _title_case_words(value: str) -> str:
    return " ".join(word.capitalize() for word in value.split() if word.strip())


def _find_email(text: str) -> str:
    match = re.search(r"[\w\.-]+@[\w\.-]+\.\w+", text)
    return match.group(0) if match else ""


def _find_name(text: str) -> str:
    lines = [line.strip() for line in text.splitlines() if line.strip()]
    if not lines:
        return "Candidate"
    first_line = lines[0]
    if len(first_line.split()) <= 5:
        return _title_case_words(first_line)
    return "Candidate"


def _guess_roles(text: str) -> List[str]:
    roles = []
    for role in [
        "Software Engineer",
        "Flutter Developer",
        "Product Designer",
        "Product Manager",
        "UX Designer",
        "Data Analyst",
        "Marketing Manager",
    ]:
        if role.lower() in text.lower():
            roles.append(role)
    return roles or ["Product Specialist"]


def _guess_skills(text: str) -> List[str]:
    found = [skill for skill in KNOWN_SKILLS if skill.lower() in text.lower()]
    return found[:8] or ["Communication", "Problem Solving", "Project Ownership"]


def _guess_seniority(years_experience: int) -> str:
    if years_experience >= 8:
        return "Senior"
    if years_experience >= 4:
        return "Mid-Senior"
    if years_experience >= 2:
        return "Mid-Level"
    return "Junior"


def _extract_years(text: str) -> int:
    match = re.search(r"(\d+)\+?\s+years", text.lower())
    return int(match.group(1)) if match else 3


def build_resume_output(payload: Dict[str, Any]) -> Dict[str, Any]:
    input_data = payload.get("input", {})
    target_role = _as_text(input_data.get("target_role"), "the target role")
    years = int(input_data.get("years_of_experience") or 0)
    past_roles = _as_list(input_data.get("past_roles"))
    skills = _as_list(input_data.get("top_skills"))
    achievements = _as_list(input_data.get("achievements"))
    education = _as_text(input_data.get("education"))
    tone = _as_text(input_data.get("preferred_tone"), "professional").lower()

    highlight_role = past_roles[0] if past_roles else "relevant experience"
    highlight_achievement = (
        achievements[0]
        if achievements
        else "delivered measurable outcomes through strong collaboration and execution"
    )

    summary = (
        f"{_title_case_words(tone)} candidate targeting {target_role} with "
        f"{years or 3}+ years of experience across {highlight_role}. "
        f"Known for {highlight_achievement} and translating experience into clear, ATS-friendly positioning."
    )

    bullets = [
        f"Positioned experience for {target_role} opportunities with concise, impact-oriented resume language.",
        f"Highlighted strengths in {', '.join(skills[:3]) if skills else 'cross-functional collaboration'} to align with common screening keywords.",
        f"Reframed accomplishments like '{highlight_achievement}' into recruiter-friendly outcome bullets.",
    ]
    if past_roles:
        bullets.append(
            f"Connected prior roles such as {', '.join(past_roles[:2])} to the requirements of {target_role}."
        )

    return {
        "summary": summary,
        "experience_bullets": bullets,
        "skills": skills or ["Communication", "Problem Solving", "Execution"],
        "education": education,
    }


def build_cover_letter_output(payload: Dict[str, Any]) -> Dict[str, Any]:
    input_data = payload.get("input", {})
    company = _as_text(input_data.get("company_name"), "the company")
    role = _as_text(input_data.get("role_title"), "the role")
    tone = _as_text(input_data.get("tone"), "professional")
    background = _as_text(input_data.get("user_background"), "a strong background in relevant work")
    candidate_profile = input_data.get("candidate_profile") or {}
    fit_analysis = input_data.get("fit_analysis") or {}

    strengths = _as_list(fit_analysis.get("strengths"))
    positioning = _as_text(
        fit_analysis.get("positioning_summary"),
        "I can contribute quickly while bringing structured execution and strong ownership.",
    )
    candidate_name = _as_text(candidate_profile.get("name"), "Candidate")
    candidate_roles = _as_list(candidate_profile.get("roles"))
    role_line = candidate_roles[0] if candidate_roles else background

    cover_letter = f"""Dear Hiring Team at {company},

I am excited to apply for the {role} opportunity. With a {tone.lower()} communication style and experience rooted in {role_line}, I am confident I can contribute meaningful results in this role.

What stands out most about this opportunity is the chance to bring my background in {background} into a team that values clear execution and thoughtful problem solving. {positioning}

I would bring strengths in {", ".join(strengths[:3]) if strengths else "structured communication, collaboration, and delivery"}, and I am particularly motivated to translate that into measurable impact for {company}.

Thank you for your time and consideration. I would welcome the opportunity to discuss how my experience can support your team.

Sincerely,
{candidate_name}
"""

    return {"cover_letter": cover_letter.strip()}


def build_interview_output(payload: Dict[str, Any]) -> Dict[str, Any]:
    input_data = payload.get("input", {})
    role = _as_text(input_data.get("role_name"), "this role")
    seniority = _as_text(input_data.get("seniority"), "mid-level")
    interview_type = _as_text(input_data.get("interview_type"), "general")
    focus_areas = _as_list(input_data.get("focus_areas"))
    focus_line = ", ".join(focus_areas[:3]) if focus_areas else "execution, collaboration, and prioritization"

    technical = [
        {
            "question": f"What would your first 30 days look like in a {seniority} {role} position?",
            "sample_answer": f"I would first understand the product, team priorities, and success metrics, then focus on a small but high-leverage win while building trust with key stakeholders.",
        },
        {
            "question": f"How do you approach problem solving for {role} work involving {focus_line}?",
            "sample_answer": "I break the problem into scope, constraints, stakeholders, and measurable outcomes, then propose an iterative solution with clear tradeoffs.",
        },
    ]
    behavioral = [
        {
            "question": f"Tell me about a time you handled ambiguity in a {interview_type} interview scenario.",
            "sample_answer": "I aligned stakeholders around the problem definition, set a lightweight decision-making framework, and kept communication frequent so progress stayed visible.",
        },
        {
            "question": "Describe a time you received difficult feedback and how you responded.",
            "sample_answer": "I listened without becoming defensive, clarified the underlying concern, and turned the feedback into a concrete improvement plan with follow-up.",
        },
    ]
    return {
        "technical_questions": technical,
        "behavioral_questions": behavioral,
    }


def build_cv_parse_output(payload: Dict[str, Any]) -> Dict[str, Any]:
    input_data = payload.get("input", {})
    cv_text = _as_text(input_data.get("cv_text"))
    name = _find_name(cv_text)
    email = _find_email(cv_text)
    years = _extract_years(cv_text)
    roles = _guess_roles(cv_text)
    skills = _guess_skills(cv_text)

    return {
        "name": name,
        "email": email,
        "location": "Remote / Open to relocation",
        "years_experience": years,
        "roles": roles,
        "skills": skills,
        "industries": ["Technology"],
        "seniority": _guess_seniority(years),
        "education": "Bachelor's degree",
    }


def build_job_match_output(payload: Dict[str, Any]) -> Dict[str, Any]:
    input_data = payload.get("input", {})
    candidate_profile = input_data.get("candidate_profile") or {}
    selected_job = input_data.get("selected_job") or {}
    candidate_skills = {skill.lower() for skill in _as_list(candidate_profile.get("skills"))}
    job_text = " ".join(
        [
            _as_text(selected_job.get("title")),
            _as_text(selected_job.get("job_description")),
        ]
    ).lower()

    matched = [skill for skill in KNOWN_SKILLS if skill.lower() in job_text and skill.lower() in candidate_skills]
    missing = [skill for skill in KNOWN_SKILLS if skill.lower() in job_text and skill.lower() not in candidate_skills][:3]
    score = min(95, 60 + len(matched) * 7 - len(missing) * 2)
    strengths = matched[:3] or ["Relevant experience", "Clear communication", "Ownership mindset"]

    return {
        "match_score": score,
        "missing_skills": missing,
        "strengths": strengths,
        "positioning_summary": "Lead with the closest transferable wins, show role-specific execution, and keep the narrative focused on measurable impact.",
    }


def build_video_intro_output(payload: Dict[str, Any]) -> Dict[str, Any]:
    input_data = payload.get("input", {})
    duration = _as_text(input_data.get("duration"), "60 sec")
    target_role = _as_text(input_data.get("target_role"), "this role")
    target_company = _as_text(input_data.get("target_company"), "your team")
    candidate_profile = input_data.get("candidate_profile") or {}
    candidate_name = _as_text(candidate_profile.get("name"), "Hi, I'm the candidate")
    key_points = _as_list(input_data.get("key_points"))
    summary_point = key_points[0] if key_points else "turning experience into measurable results"

    script = (
        f"Hi, I'm {candidate_name}. I'm excited to be considered for the {target_role} role at {target_company}. "
        f"My background has centered on {summary_point}, and I enjoy bringing clear communication, ownership, and thoughtful execution to the teams I work with. "
        f"I'm especially interested in this opportunity because it feels like a strong match for both my experience and the kind of impact I want to keep building. "
        f"Thank you for your time."
    )

    return {"script": script, "duration": duration}


def build_output(task: str, payload: Dict[str, Any]) -> Dict[str, Any]:
    if task == "resume_generate":
        return build_resume_output(payload)
    if task == "cover_letter_generate":
        return build_cover_letter_output(payload)
    if task == "interview_generate":
        return build_interview_output(payload)
    if task == "cv_parse":
        return build_cv_parse_output(payload)
    if task == "job_match":
        return build_job_match_output(payload)
    if task == "video_introduction_generate":
        return build_video_intro_output(payload)
    raise ValueError(f"Unsupported task: {task}")


class Handler(BaseHTTPRequestHandler):
    server_version = "AICareerStub/1.0"

    def _write_json(self, status: int, payload: Dict[str, Any]) -> None:
        body = json.dumps(payload).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self) -> None:
        if self.path == "/health":
            self._write_json(
                200,
                {"status": "ok", "service": "local-ai-stub", "time": datetime.utcnow().isoformat()},
            )
            return
        self._write_json(404, {"error": "Not found"})

    def do_POST(self) -> None:
        if self.path != "/v1/ai/tasks":
            self._write_json(404, {"error": "Not found"})
            return

        length = int(self.headers.get("Content-Length", "0"))
        raw = self.rfile.read(length).decode("utf-8")

        try:
            payload = json.loads(raw or "{}")
            task = str(payload.get("task", "")).strip()
            if not task:
                self._write_json(400, {"error": "Missing task"})
                return

            output = build_output(task, payload)
            response = {
                "request_id": f"stub_{task}_{int(datetime.utcnow().timestamp())}",
                "task": task,
                "model": "local-ai-stub-v1",
                "output": output,
            }
            self._write_json(200, response)
        except ValueError as error:
            self._write_json(400, {"error": str(error)})
        except Exception as error:
            self._write_json(500, {"error": f"Stub server failed: {error}"})

    def log_message(self, format: str, *args: Any) -> None:
        print(f"[local-ai-stub] {self.address_string()} - {format % args}")


if __name__ == "__main__":
    server = ThreadingHTTPServer((HOST, PORT), Handler)
    print(f"Local AI stub listening on http://{HOST}:{PORT}")
    server.serve_forever()
