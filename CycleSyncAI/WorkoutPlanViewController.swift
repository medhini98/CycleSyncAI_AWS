import UIKit

class WorkoutPlanViewController: UIViewController {

    let backButton = UIButton(type: .system)
    let promptLabel = UILabel()
    let generateButton = UIButton(type: .system)
    let gradientLayer = CAGradientLayer()
    let workoutPlanContainerView = UIView()
    let workoutPlanTextView = UITextView()

    var userProfileData: UserProfile?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupBackButton()
        setupPromptLabel()
        setupGenerateButton()
        setupWorkoutPlanTextView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    func setupGradientBackground() {
        gradientLayer.colors = [
            UIColor(red: 255/255, green: 224/255, blue: 229/255, alpha: 1).cgColor,
            UIColor(red: 230/255, green: 220/255, blue: 255/255, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    func setupBackButton() {
        backButton.setTitle("← Back", for: .normal)
        backButton.titleLabel?.font = UIFont(name: "Avenir", size: 16)
        backButton.setTitleColor(.white, for: .normal)
        backButton.layer.cornerRadius = 12
        backButton.translatesAutoresizingMaskIntoConstraints = false

        // Apply gradient to back button
        let backGradient = CAGradientLayer()
        backGradient.colors = [
            UIColor(red: 204/255, green: 193/255, blue: 247/255, alpha: 1).cgColor,
            UIColor(red: 169/255, green: 198/255, blue: 255/255, alpha: 1).cgColor
        ]
        backGradient.startPoint = CGPoint(x: 0, y: 0)
        backGradient.endPoint = CGPoint(x: 1, y: 1)
        backGradient.frame = CGRect(x: 0, y: 0, width: 80, height: 36)
        backGradient.cornerRadius = 12
        backButton.layer.insertSublayer(backGradient, at: 0)

        backButton.addTarget(self, action: #selector(goBackToHome), for: .touchUpInside)
        view.addSubview(backButton)

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 80),
            backButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    func setupPromptLabel() {
        promptLabel.text = "Click here to get a personalized workout plan within minutes!"
        promptLabel.font = UIFont(name: "Avenir", size: 16)
        promptLabel.textAlignment = .center
        promptLabel.textColor = UIColor(red: 102/255, green: 51/255, blue: 153/255, alpha: 1)
        promptLabel.numberOfLines = 0
        promptLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(promptLabel)

        NSLayoutConstraint.activate([
            promptLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 20),
            promptLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            promptLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    func setupGenerateButton() {
        generateButton.setTitle("Generate Workout Plan", for: .normal)
        generateButton.titleLabel?.font = UIFont(name: "Avenir", size: 18)
        generateButton.setTitleColor(.white, for: .normal)
        generateButton.layer.cornerRadius = 12
        generateButton.translatesAutoresizingMaskIntoConstraints = false

        let buttonGradient = CAGradientLayer()
        buttonGradient.colors = [
            UIColor(red: 204/255, green: 193/255, blue: 247/255, alpha: 1).cgColor,
            UIColor(red: 169/255, green: 198/255, blue: 255/255, alpha: 1).cgColor
        ]
        buttonGradient.startPoint = CGPoint(x: 0, y: 0)
        buttonGradient.endPoint = CGPoint(x: 1, y: 1)
        buttonGradient.frame = CGRect(x: 0, y: 0, width: 200, height: 50)
        buttonGradient.cornerRadius = 12
        generateButton.layer.insertSublayer(buttonGradient, at: 0)

        generateButton.addTarget(self, action: #selector(generateWorkoutPlan), for: .touchUpInside)
        view.addSubview(generateButton)

        NSLayoutConstraint.activate([
            generateButton.topAnchor.constraint(equalTo: promptLabel.bottomAnchor, constant: 20),
            generateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            generateButton.widthAnchor.constraint(equalToConstant: 200),
            generateButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func formattedDateLabel(start: Date = Date(), end: Date? = nil) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"

        if let end = end {
            return "\(dateFormatter.string(from: start))–\(dateFormatter.string(from: end)) • \(timeFormatter.string(from: Date()))"
        } else {
            return "\(dateFormatter.string(from: start)) • \(timeFormatter.string(from: Date()))"
        }
    }

    @objc func generateWorkoutPlan() {
        print("✅ Generate Workout Plan button tapped!")

        guard let profile = self.userProfileData else {
            print("❌ No user profile data found.")
            self.workoutPlanTextView.text = "⚠️ Please complete your user profile first."
            return
        }

        HealthManager.shared.requestAuthorization { success, error in
            if success {
                HealthManager.shared.fetchCurrentCycleStartDate { startDate in
                    guard let startDate = startDate else {
                        DispatchQueue.main.async {
                            self.workoutPlanTextView.text = "⚠️ No menstrual data found. Please log your period in the Health app."
                        }
                        return
                    }

                    let cycleDay = HealthManager.shared.calculateCycleDay(from: startDate) ?? -1
                    let phase = HealthManager.shared.determinePhase(for: cycleDay, menstrualEndDay: HealthManager.shared.lastMenstrualEndDay)

                    print("✅ Cycle Day: \(cycleDay), Phase: \(phase)")

                    DispatchQueue.main.async {
                        self.buildAndSendWorkoutPrompt(phase: phase, cycleDay: cycleDay)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.workoutPlanTextView.text = "⚠️ HealthKit authorization failed."
                }
            }
        }
    }

    func buildAndSendWorkoutPrompt(phase: String, cycleDay: Int) {
        guard let profile = self.userProfileData else { return }

        let workoutPrompt = """
        You are an expert nutritionist and women's fitness trainer. Generate a complete, formatted HTML document. Answers should be direct and to the point.

        - Use <h2> for section headings.
        - Use <b> for important terms.
        - Use <ul><li> lists for bullet points.
        - Use <p> to separate paragraphs.

        Provide:

        1. A brief bullet list (5–6 points) summarizing the key exercise/movement focuses and priorities relevant to the user’s menstrual phase \(phase), goal \(profile.goal), activity level \(profile.activityLevel), age group \(profile.ageGroup), medical conditions \(profile.medicalConditions), and dietary restrictions \(profile.dietaryRestrictions).

        2. Generate a personalized workout plan for a \(profile.ageGroup) woman, \(profile.height), \(profile.weight), with \(profile.medicalConditions) and \(profile.dietaryRestrictions), on day \(cycleDay) of her menstrual cycle (\(phase) phase). The user's goal is \(profile.goal) and current activity level is \(profile.activityLevel). Include workout timings. Title this section as ‘Personalized Workout Plan’ (no need to include age, height, weight, or phase details in the subheading).

        Inside the Personalized Workout Plan section:
        - Include a Workout Intensity subheading and state the intensity level (Low, Medium, or High), based on the menstrual phase \(phase).
        - Include the main workout category for the phase.
        - Provide detailed exercise names or specific instructions under each category so the user can follow a clear, actionable routine.
        - For each exercise, include a brief (1-line) explanation of what the exercise is or how to do it, written simply for someone new to fitness.
        - When mentioning weights (e.g., dumbbells, resistance), suggest the weight in kg and include the equivalent in lbs, tailoring recommendations to the phase \(phase), goal \(profile.goal), activity level \(profile.activityLevel), age group \(profile.ageGroup), and medical conditions \(profile.medicalConditions).
        - Add a dumbbell icon 🏋️ next to weight recommendations.
        - If suggesting household substitutes (like water bottles), label this in the workout details.
        - Add hydration instructions alongside the workout steps, highlighted using a water drop icon 💧 or hydration checklist.

        While generating the workout plan, use the following menstrual phase exercise intensity guidelines:
        - Menstrual (days 1–7): Low or no intensity → suggest light walks, gentle yoga, or light strength/cardio.
        - Follicular (days 8–14): Medium to high intensity → suggest brisk walks, weight training, high-intensity exercises, or swimming.
        - Ovulation (days 15–20): High intensity → suggest HIIT, cardio, spin classes, circuits, or swimming.
        - Mid Luteal (days 21–24): Low to medium intensity → suggest swimming, gentle strength training, or Pilates.
        - Late Luteal (days 25–35): Low intensity → suggest restorative yoga, long walks, or stretching.

        Explanations and suggestions throughout should be phase-based, as this is the core focus of the app.

        3. Provide a brief (2–3 sentence) explanation of why the recommended workout is helpful during the \(phase) phase, including which muscles it targets and why the warm-up and cool-down are important, taking into account the user’s age, goal, and medical conditions.

        4. Add a one-line suggestion for ideal wake-up and bedtime routines for this user, based on their age, activity, and goal.

        5. Provide additional quick movement tips (not mentioned in the main workout plan) to help achieve \(profile.goal) during the \(phase) phase, considering the user’s medical conditions \(profile.medicalConditions) and dietary restrictions \(profile.dietaryRestrictions).

        6. Provide an approximate estimate of total calories burned for the workout, tailored to the user’s weight \(profile.weight), intensity, and activity type.

        7. Add a kind, appreciative line recognizing the user’s commitment to their health. Optionally include a motivational line if it aligns well with the user’s goal (\(profile.goal)).

        8. Include a <h2>Sources</h2> section listing all real, verifiable citations used in the plan. Format each citation on a separate line, numbered like:
        [1] https://...
        [2] https://...
        [3] https://...
        [4] https://...

        These sources should come from reputable resources (scientific publications, health sites, or official guidelines). Omit if no reliable citation is available.

        Separate each section clearly using headings (do not label them as ‘Task 1’, ‘Task 2’, etc.).

        While generating the workout plan, ensure you:
        - Suggest workout plans/exercises that support \(phase), \(profile.medicalConditions), and \(profile.goal).
        - Include exercises beneficial for women in age group \(profile.ageGroup).
        - Avoid any exercises harmful or exacerbating for \(profile.medicalConditions).
        - Respect all \(profile.dietaryRestrictions).
        - Avoid exercises that may worsen PMS or related symptoms during \(phase).
        """

        print("✅ Workout Prompt Generated:\n\(workoutPrompt)")
        
        self.callSonarAPI(with: workoutPrompt)
    }
    
    func setupWorkoutPlanTextView() {
        // Card container
        workoutPlanContainerView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        workoutPlanContainerView.layer.cornerRadius = 16
        workoutPlanContainerView.layer.shadowColor = UIColor.black.cgColor
        workoutPlanContainerView.layer.shadowOpacity = 0.1
        workoutPlanContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        workoutPlanContainerView.layer.shadowRadius = 6
        workoutPlanContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(workoutPlanContainerView)

        // Text view inside card
        workoutPlanTextView.isEditable = false
        workoutPlanTextView.isScrollEnabled = true
        workoutPlanTextView.backgroundColor = .clear
        workoutPlanTextView.textColor = UIColor(red: 102/255, green: 51/255, blue: 153/255, alpha: 1)
        workoutPlanTextView.font = UIFont(name: "Avenir", size: 16)
        workoutPlanTextView.translatesAutoresizingMaskIntoConstraints = false
        workoutPlanContainerView.addSubview(workoutPlanTextView)

        NSLayoutConstraint.activate([
            // Container position
            workoutPlanContainerView.topAnchor.constraint(equalTo: generateButton.bottomAnchor, constant: 30),
            workoutPlanContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            workoutPlanContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            workoutPlanContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),

            // Text view inside container
            workoutPlanTextView.topAnchor.constraint(equalTo: workoutPlanContainerView.topAnchor, constant: 12),
            workoutPlanTextView.leadingAnchor.constraint(equalTo: workoutPlanContainerView.leadingAnchor, constant: 12),
            workoutPlanTextView.trailingAnchor.constraint(equalTo: workoutPlanContainerView.trailingAnchor, constant: -12),
            workoutPlanTextView.bottomAnchor.constraint(equalTo: workoutPlanContainerView.bottomAnchor, constant: -12)
        ])
    }
    
    func callSonarAPI(with prompt: String) {
        guard let url = URL(string: "https://api.perplexity.ai/chat/completions") else {
            print("❌ Invalid API URL.")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer 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", forHTTPHeaderField: "Authorization")

        let requestBody: [String: Any] = [
            "model": "sonar-pro",
            "messages": [["role": "user", "content": prompt]]
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            print("❌ Failed to encode request body: \(error)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ API error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("❌ No data received from API.")
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                if let choices = json?["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String {

                    print("✅ Got API content!")
                    
                    // ✅ Add this to print raw content length and raw text
                        print("✅ Raw API content length: \(content.count)")
                        print("✅ Raw API content:\n\(content)")

                    // 💡 Strip ```html ... ``` if present
                    var cleanedContent = content
                    if cleanedContent.hasPrefix("```html") && cleanedContent.hasSuffix("```") {
                        cleanedContent = cleanedContent
                            .replacingOccurrences(of: "```html", with: "")
                            .replacingOccurrences(of: "```", with: "")
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                    }

                    if let htmlData = cleanedContent.data(using: .utf8) {
                        do {
                            let attributedString = try NSAttributedString(
                                data: htmlData,
                                options: [.documentType: NSAttributedString.DocumentType.html,
                                          .characterEncoding: String.Encoding.utf8.rawValue],
                                documentAttributes: nil)
                            DispatchQueue.main.async {
                                self.workoutPlanTextView.attributedText = attributedString
                                
                                let plan = PlanModel(
                                    type: "workout",
                                    dateLabel: self.formattedDateLabel(start: Date(), end: nil),
                                    content: content
                                )
                                PlanHistoryManager.shared.savePlan(plan)
                                print("✅ Workout plan saved to history!")
                            }
                        } catch {
                            print("❌ Failed to render API HTML: \(error)")
                            DispatchQueue.main.async {
                                self.workoutPlanTextView.text = "⚠️ Failed to render workout plan."
                            }
                        }
                    }

                } else {
                    print("❌ Unexpected API response format.")
                }
            } catch {
                print("❌ Failed to parse API response: \(error)")
            }
        }

        task.resume()
    }

    @objc func goBackToHome() {
        dismiss(animated: true, completion: nil)
    }
}
