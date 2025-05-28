import UIKit

class EatPlanViewController: UIViewController {

    let backButton = UIButton(type: .system)
    let promptLabel = UILabel()
    let mealPreferenceField = UITextField()
    let generateButton = UIButton(type: .system)
    let dietPlanTextView = UITextView()
    let gradientLayer = CAGradientLayer()
    let dietPlanContainerView = UIView()
    
    let sectionTextColor = UIColor(red: 230/255, green: 100/255, blue: 140/255, alpha: 1)  // #E6648C
    
    var userProfileData: UserProfile?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupBackButton()
        setupPromptLabel()
        setupMealPreferenceField()
        setupGenerateButton()
        setupDietPlanTextView()
        setupTapToDismissKeyboard()

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
        
        styleEatPlanButton(backButton)
        styleEatPlanButton(generateButton)
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
        backButton.backgroundColor = UIColor(red: 230/255, green: 130/255, blue: 150/255, alpha: 1)
        backButton.layer.cornerRadius = 12
        backButton.clipsToBounds = true
        backButton.layer.shadowColor = UIColor.black.cgColor
        backButton.layer.shadowOpacity = 0.2
        backButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        backButton.layer.shadowRadius = 6
        backButton.translatesAutoresizingMaskIntoConstraints = false
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
        promptLabel.text = "What do you feel like eating today?"
        promptLabel.font = UIFont(name: "Avenir", size: 18)
        promptLabel.textAlignment = .center
        promptLabel.textColor = sectionTextColor
        promptLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(promptLabel)

        NSLayoutConstraint.activate([
            promptLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 12),
            promptLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            promptLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    func setupMealPreferenceField() {
        mealPreferenceField.placeholder = "Optional: e.g., South Indian"
        mealPreferenceField.borderStyle = .roundedRect
        mealPreferenceField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mealPreferenceField)

        NSLayoutConstraint.activate([
            mealPreferenceField.topAnchor.constraint(equalTo: promptLabel.bottomAnchor, constant: 10),
            mealPreferenceField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mealPreferenceField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            mealPreferenceField.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    func setupGenerateButton() {
        let taglineLabel = UILabel()
        taglineLabel.text = "Click below to get a personalized plan in minutes!"
        taglineLabel.font = UIFont(name: "Avenir", size: 16)
        taglineLabel.textAlignment = .center
        taglineLabel.textColor = sectionTextColor
        taglineLabel.numberOfLines = 0
        taglineLabel.lineBreakMode = .byWordWrapping
        taglineLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(taglineLabel)

        generateButton.setTitle("Generate Diet Plan", for: .normal)
        generateButton.titleLabel?.font = UIFont(name: "Avenir", size: 18)
        generateButton.setTitleColor(.white, for: .normal)
        generateButton.backgroundColor = UIColor(red: 230/255, green: 130/255, blue: 150/255, alpha: 1)  // pastel rose
        generateButton.layer.cornerRadius = 12
        generateButton.translatesAutoresizingMaskIntoConstraints = false
        generateButton.addTarget(self, action: #selector(generateDietPlan), for: .touchUpInside)
        view.addSubview(generateButton)
        
        NSLayoutConstraint.activate([
            taglineLabel.topAnchor.constraint(equalTo: mealPreferenceField.bottomAnchor, constant: 12),
            taglineLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            taglineLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            generateButton.topAnchor.constraint(equalTo: taglineLabel.bottomAnchor, constant: 16),
            generateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            generateButton.widthAnchor.constraint(equalToConstant: 200),
            generateButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    func setupDietPlanTextView() {
        // Add container view (card-like)
        dietPlanContainerView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        dietPlanContainerView.layer.cornerRadius = 16
        dietPlanContainerView.layer.shadowColor = UIColor.black.cgColor
        dietPlanContainerView.layer.shadowOpacity = 0.1
        dietPlanContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        dietPlanContainerView.layer.shadowRadius = 6
        dietPlanContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dietPlanContainerView)

        // Add the text view inside the container
        dietPlanTextView.isEditable = false
        dietPlanTextView.isScrollEnabled = true
        dietPlanTextView.backgroundColor = .clear
        dietPlanTextView.textColor = sectionTextColor
        dietPlanTextView.font = UIFont(name: "Avenir", size: 16)
        dietPlanTextView.translatesAutoresizingMaskIntoConstraints = false
        dietPlanContainerView.addSubview(dietPlanTextView)

        NSLayoutConstraint.activate([
            // Container takes up more height on the screen
            dietPlanContainerView.topAnchor.constraint(equalTo: generateButton.bottomAnchor, constant: 30),
            dietPlanContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dietPlanContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            dietPlanContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),

            // Text view fills the container with padding
            dietPlanTextView.topAnchor.constraint(equalTo: dietPlanContainerView.topAnchor, constant: 12),
            dietPlanTextView.leadingAnchor.constraint(equalTo: dietPlanContainerView.leadingAnchor, constant: 12),
            dietPlanTextView.trailingAnchor.constraint(equalTo: dietPlanContainerView.trailingAnchor, constant: -12),
            dietPlanTextView.bottomAnchor.constraint(equalTo: dietPlanContainerView.bottomAnchor, constant: -12)
        ])
    }

    @objc func generateDietPlan() {
        print("✅ Generate Diet Plan button tapped!")

        guard self.userProfileData != nil else {
            print("❌ No user profile data found.")
            self.dietPlanTextView.text = "⚠️ Please complete your user profile first."
            return
        }

        HealthManager.shared.requestAuthorization { success, error in
            if success {
                HealthManager.shared.fetchCurrentCycleStartDate { startDate in
                    guard let startDate = startDate else {
                        DispatchQueue.main.async {
                            self.dietPlanTextView.text = "⚠️ No menstrual data found. Please log your period in the Health app."
                        }
                        return
                    }

                    let cycleDay = HealthManager.shared.calculateCycleDay(from: startDate) ?? -1
                    let phase = HealthManager.shared.determinePhase(for: cycleDay, menstrualEndDay: HealthManager.shared.lastMenstrualEndDay)

                    print("✅ Cycle Day: \(cycleDay), Phase: \(phase)")

                    DispatchQueue.main.async {
                        self.buildAndSendPrompt(phase: phase, cycleDay: cycleDay)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.dietPlanTextView.text = "⚠️ HealthKit authorization failed."
                }
            }
        }
    }
    
    func buildAndSendPrompt(phase: String, cycleDay: Int) {
        guard let profile = self.userProfileData else {
            self.dietPlanTextView.text = "⚠️ Please complete your user profile first."
            return
        }

        let preference = self.mealPreferenceField.text ?? "No preference"

        let prompt = """
        You are an expert nutritionist. Please generate a complete, formatted HTML document.

        - Use <h2> for section headings.
        - Use <b> for important terms.
        - Use <ul><li> lists for bullet points.
        - Use <p> to separate paragraphs.

        Provide:
        1. A brief bullet list (5–6 points) summarizing the key dietary focuses and nutritional priorities relevant to the user’s menstrual phase \(phase), goal \(profile.goal), activity level \(profile.activityLevel), age group \(profile.ageGroup), medical conditions \(profile.medicalConditions), and dietary restrictions \(profile.dietaryRestrictions).

        2. Generate a personalized diet plan for a \(profile.ageGroup) woman, \(profile.height), \(profile.weight), with \(profile.medicalConditions) and \(profile.dietaryRestrictions), on day \(cycleDay) of her menstrual cycle (\(phase) phase). The user's goal is \(profile.goal) and current activity level is \(profile.activityLevel). Meal preference for today is \(preference). Include meal timings as well for each meal. Title this section as ‘Personalized Diet Plan’ (no need to include age, height, weight, or phase details in the subheading). Make sure to include seed suggestion in the diet based on \(phase) like 'Eat Flax & pumpkin seeds 🎃.' Make sure to include hydration instructions based on \(profile.ageGroup), \(profile.height), \(profile.weight), \(phase), \(profile.medicalConditions), \(profile.activityLevel), and \(profile.goal). Include meal timings.

        3. Provide a brief (2–3 sentence) explanation of why eating the recommended seeds is helpful during the \(phase) phase.

        4. Add a one-line suggestion for ideal wake-up and bedtime routines for this user, based on their age, activity, and goal.

        5. Provide additional quick diet tips (not mentioned in the main diet plan) to help achieve \(profile.goal) during the \(phase) phase, considering the user’s medical conditions \(profile.medicalConditions) and dietary restrictions \(profile.dietaryRestrictions).
        
        6. Provide a concise grocery list for today’s meals, focusing on fresh, special, or phase-specific ingredients, excluding common pantry staples.

        7. A kind, appreciative line recognizing the user’s commitment to their health. Optionally include a motivational line if it aligns well with the user’s goal (\(profile.goal)).

        8. At the end, include a <h2>Sources</h2> section listing all the real, verifiable citations you used, numbered like. Format each citation on a separate line, like:
        [1] https://...
        [2] https://...
        [3] https://...
        [4] https://...
        etc.

        These sources should be real, verifiable, and drawn from reputable resources (such as scientific publications, reputable health sites, or official guidelines). If no reliable citation is available, omit rather than fabricating one.

        Please separate responses for each section clearly using headings (but do not label them as ‘Task 1’, ‘Task 2’, etc.).

        While generating the diet plan and creating the grocery list, ensure you:
        - Suggest meals/ingredients that support \(phase), \(profile.medicalConditions), and \(profile.goal).
        - Include foods beneficial for women in age group \(profile.ageGroup).
        - Avoid any foods harmful or exacerbating for \(profile.medicalConditions).
        - Respect all \(profile.dietaryRestrictions).
        - Avoid foods that may worsen PMS or related symptoms during \(phase).
        """

        callSonarAPI(with: prompt)
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
                   var content = message["content"] as? String {

                    print("✅ Got API content!")

                    // 💡 Strip ```html ... ``` if present
                    if content.hasPrefix("```html") && content.hasSuffix("```") {
                        content = content
                            .replacingOccurrences(of: "```html", with: "")
                            .replacingOccurrences(of: "```", with: "")
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                    }

                    if let htmlData = content.data(using: .utf8) {
                        do {
                            let attributedString = try NSAttributedString(
                                data: htmlData,
                                options: [.documentType: NSAttributedString.DocumentType.html,
                                          .characterEncoding: String.Encoding.utf8.rawValue],
                                documentAttributes: nil)
                            DispatchQueue.main.async {
                                self.dietPlanTextView.attributedText = attributedString
                            }
                        } catch {
                            print("❌ Failed to render API HTML: \(error)")
                            DispatchQueue.main.async {
                                self.dietPlanTextView.text = "⚠️ Failed to render diet plan."
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
    
    func styleEatPlanButton(_ button: UIButton) {
        button.setTitleColor(.white, for: .normal)  // ✅ white text
        button.titleLabel?.font = UIFont(name: "Avenir", size: 18)
        button.layer.cornerRadius = 12
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 6

        button.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = button.bounds
        gradientLayer.cornerRadius = 12
        gradientLayer.colors = [
            UIColor(red: 1.0, green: 0.765, blue: 0.725, alpha: 1).cgColor,    // #FFC3B9
            UIColor(red: 0.996, green: 0.698, blue: 0.863, alpha: 1).cgColor   // #FEB2DC
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)

        button.layer.insertSublayer(gradientLayer, at: 0)
    }

    func setupTapToDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func goBackToHome() {
        dismiss(animated: true, completion: nil)
    }
}
