import '../domain/interview_question.dart';

class MockQuestionGenerator {
  static List<InterviewQuestion> generate({
    required String role,
    required String seniority,
  }) {
    final technical = _technicalQuestions(role, seniority);
    final behavioral = _behavioralQuestions(seniority);
    return [...technical, ...behavioral];
  }

  // ─── Technical ────────────────────────────────────────────────────────────

  static List<InterviewQuestion> _technicalQuestions(
    String role,
    String seniority,
  ) {
    final r = role.toLowerCase();

    if (r.contains('flutter') || r.contains('mobile')) {
      return _flutterQuestions(seniority);
    } else if (r.contains('frontend') ||
        r.contains('front-end') ||
        r.contains('react') ||
        r.contains('vue')) {
      return _frontendQuestions(seniority);
    } else if (r.contains('backend') ||
        r.contains('back-end') ||
        r.contains('node') ||
        r.contains('python') ||
        r.contains('java')) {
      return _backendQuestions(seniority);
    } else if (r.contains('data') ||
        r.contains('ml') ||
        r.contains('machine learning')) {
      return _dataQuestions(seniority);
    } else if (r.contains('devops') ||
        r.contains('cloud') ||
        r.contains('infra')) {
      return _devopsQuestions(seniority);
    } else {
      return _generalSweQuestions(seniority);
    }
  }

  static List<InterviewQuestion> _flutterQuestions(String seniority) {
    final isJunior = seniority == 'Junior';
    final isSeniorPlus = seniority == 'Senior' || seniority == 'Lead';

    return [
      const InterviewQuestion(
        category: QuestionCategory.technical,
        question:
            'What is the difference between StatelessWidget and StatefulWidget?',
        sampleAnswer:
            'A StatelessWidget is immutable — it builds once and never changes. It\'s suitable for UI that depends only on its constructor parameters. A StatefulWidget, on the other hand, has a mutable State object that can call setState() to trigger rebuilds when data changes. I use StatelessWidget by default and reach for StatefulWidget only when local mutable state is truly needed, often preferring Riverpod providers to avoid lifting state into widgets.',
      ),
      const InterviewQuestion(
        category: QuestionCategory.technical,
        question:
            'How does Flutter\'s widget tree, element tree, and render tree relate to each other?',
        sampleAnswer:
            'Flutter maintains three parallel trees. The widget tree is the blueprint — lightweight, immutable configurations. The element tree is the live instance of that blueprint and manages lifecycle and state. The render tree handles painting and layout. When setState is called, Flutter diffs the widget tree, updates elements minimally, and only repaints changed render objects. Understanding this helps write performant widgets and avoid unnecessary rebuilds.',
      ),
      InterviewQuestion(
        category: QuestionCategory.technical,
        question: isJunior
            ? 'What is a Future and how do you use async/await in Flutter?'
            : isSeniorPlus
            ? 'How do you architect state management in a large-scale Flutter app?'
            : 'Compare Riverpod, Bloc, and Provider for state management. When would you choose each?',
        sampleAnswer: isJunior
            ? 'A Future represents an asynchronous computation that will complete with a value or an error. With async/await I can write asynchronous code that reads synchronously. For example, marking a method async and using await before a network call suspends execution until the Future completes, without blocking the UI thread.'
            : isSeniorPlus
            ? 'I prefer a layered approach: domain models, repository interfaces, and Riverpod providers at the presentation layer. Features are vertical slices. I define repository interfaces in domain, implement them in data, and expose state via AsyncNotifierProvider. This keeps business logic testable and UI thin.'
            : 'Provider is simple for small apps but doesn\'t scale well. Bloc enforces strict event/state separation — great for teams that need clarity and testability. Riverpod is my go-to: compile-safe, testable, no context dependency, and supports code generation. I use Bloc when working in larger teams that benefit from the explicit structure.',
      ),
      const InterviewQuestion(
        category: QuestionCategory.technical,
        question: 'How do you optimize Flutter app performance?',
        sampleAnswer:
            'Key strategies: use const constructors wherever possible to avoid unnecessary rebuilds; use RepaintBoundary to isolate expensive widgets; avoid doing work in build(); use ListView.builder for long lists; profile with Flutter DevTools to identify jank. I also separate business logic from widgets so state changes only rebuild the smallest possible subtree.',
      ),
      InterviewQuestion(
        category: QuestionCategory.technical,
        question: isSeniorPlus
            ? 'How would you design an offline-first architecture in Flutter?'
            : 'How do you handle navigation and deep linking in Flutter?',
        sampleAnswer: isSeniorPlus
            ? 'I use a local database (Isar or Drift) as the source of truth. The repository layer writes to local DB first, then syncs to the backend. A sync manager handles conflict resolution and retry logic. The UI observes local data via streams, so it\'s always responsive. When connectivity returns, a background isolate or WorkManager job pushes queued mutations.'
            : 'I use GoRouter for navigation. It supports named routes, path parameters, query parameters, and deep links via the GoRoute tree. For auth guards I use the redirect callback to intercept navigation based on auth state. Deep links are configured in AndroidManifest and Info.plist and handled automatically by GoRouter.',
      ),
    ];
  }

  static List<InterviewQuestion> _frontendQuestions(String seniority) {
    final isSeniorPlus = seniority == 'Senior' || seniority == 'Lead';
    return [
      const InterviewQuestion(
        category: QuestionCategory.technical,
        question: 'Explain the virtual DOM and how React uses it.',
        sampleAnswer:
            'The virtual DOM is an in-memory representation of the real DOM. When state changes, React builds a new virtual DOM tree and diffs it against the previous one (reconciliation). Only the changed nodes are applied to the real DOM, minimizing expensive DOM operations. Fiber, React\'s reconciler, does this work incrementally to keep the UI responsive.',
      ),
      const InterviewQuestion(
        category: QuestionCategory.technical,
        question:
            'What is the difference between useEffect, useMemo, and useCallback?',
        sampleAnswer:
            'useEffect runs side effects after renders — data fetching, subscriptions, DOM mutations. useMemo memoizes an expensive computed value, recomputing only when dependencies change. useCallback memoizes a function reference, preventing child components from re-rendering when the parent re-renders but the function logic hasn\'t changed. Over-using the latter two adds overhead; I reach for them only after profiling.',
      ),
      const InterviewQuestion(
        category: QuestionCategory.technical,
        question: 'What is CSS specificity and how does the cascade work?',
        sampleAnswer:
            'Specificity determines which CSS rule wins when multiple rules target the same element. It\'s calculated as (inline styles, IDs, classes/attributes/pseudo-classes, elements/pseudo-elements). Inline styles beat everything. When specificity ties, the last rule in source order wins. I prefer low-specificity selectors (classes) to keep styles maintainable and avoid the specificity arms race.',
      ),
      InterviewQuestion(
        category: QuestionCategory.technical,
        question: isSeniorPlus
            ? 'How do you approach web performance optimization?'
            : 'What are some common techniques for improving React app performance?',
        sampleAnswer: isSeniorPlus
            ? 'Core Web Vitals are my north star. I optimize LCP by preloading critical assets and server-side rendering. FID/INP by code-splitting and deferring non-critical JS. CLS by reserving space for images. I use Lighthouse, WebPageTest, and real-user monitoring. Bundle analysis with webpack-bundle-analyzer guides tree-shaking decisions.'
            : 'React.memo prevents unnecessary re-renders of functional components. Code-splitting with React.lazy reduces initial bundle size. Virtualization with react-window handles long lists. Avoiding derived state calculations in render and lifting state minimally all contribute to performance.',
      ),
      InterviewQuestion(
        category: QuestionCategory.technical,
        question: isSeniorPlus
            ? 'Describe a frontend architecture you designed for a complex application.'
            : 'How does JavaScript event loop and asynchronous programming work?',
        sampleAnswer: isSeniorPlus
            ? 'I designed a micro-frontend architecture where each team owned an independently deployed feature. A shell app composed them at runtime via module federation. Shared state used a pub/sub event bus to keep teams decoupled. Each micro-frontend had its own CI/CD pipeline. The tradeoff was coordination overhead, but it enabled six teams to ship independently.'
            : 'JavaScript is single-threaded. The call stack executes synchronous code. Async operations (network, timers) are handed off to Web APIs. Their callbacks are pushed to the task queue when complete. The event loop continuously checks if the stack is empty and processes the next task. Microtasks (Promises) have a separate higher-priority queue, drained before the next task.',
      ),
    ];
  }

  static List<InterviewQuestion> _backendQuestions(String seniority) {
    final isSeniorPlus = seniority == 'Senior' || seniority == 'Lead';
    return [
      const InterviewQuestion(
        category: QuestionCategory.technical,
        question: 'What is the difference between REST and GraphQL?',
        sampleAnswer:
            'REST uses multiple endpoints, each returning fixed data shapes. GraphQL has a single endpoint; clients specify exactly what data they need, eliminating over-fetching and under-fetching. REST is simpler and has better HTTP caching. GraphQL excels when clients have diverse data needs or when aggregating multiple resources. I choose REST for public APIs and GraphQL for internal, client-driven APIs.',
      ),
      const InterviewQuestion(
        category: QuestionCategory.technical,
        question: 'Explain database indexing and when to use it.',
        sampleAnswer:
            'An index is a data structure (typically a B-tree) that speeds up lookups at the cost of extra write overhead and storage. I add indexes on columns frequently used in WHERE clauses, JOIN conditions, and ORDER BY. Composite indexes benefit multi-column queries. I avoid over-indexing write-heavy tables. EXPLAIN ANALYZE in PostgreSQL is my tool of choice for identifying missing indexes.',
      ),
      const InterviewQuestion(
        category: QuestionCategory.technical,
        question:
            'What are the SOLID principles and how do they apply to backend development?',
        sampleAnswer:
            'Single Responsibility: each class/module does one thing. Open/Closed: open for extension, closed for modification (use interfaces). Liskov Substitution: subtypes must be substitutable for base types. Interface Segregation: prefer narrow interfaces over fat ones. Dependency Inversion: depend on abstractions. In practice this means thin controllers, service classes per use-case, and repository interfaces that separate data access from business logic.',
      ),
      InterviewQuestion(
        category: QuestionCategory.technical,
        question: isSeniorPlus
            ? 'How do you design a system for high availability and fault tolerance?'
            : 'How do you handle authentication and authorization in a REST API?',
        sampleAnswer: isSeniorPlus
            ? 'I start with redundancy — multiple instances behind a load balancer, database read replicas, and multi-AZ deployments. Circuit breakers prevent cascade failures. Graceful degradation means the system stays partially functional when a dependency is down. I use health checks, distributed tracing (OpenTelemetry), and alerting on error rate SLOs rather than just uptime.'
            : 'Authentication verifies identity — I use JWT or session tokens issued at login. Authorization verifies permissions — role-based access control (RBAC) or attribute-based. JWTs are stateless but can\'t be revoked without a denylist; sessions require server-side storage. I always hash passwords with bcrypt, use HTTPS, and enforce token expiry.',
      ),
      InterviewQuestion(
        category: QuestionCategory.technical,
        question: isSeniorPlus
            ? 'Walk me through how you would design a distributed message queue.'
            : 'What is the difference between SQL and NoSQL databases?',
        sampleAnswer: isSeniorPlus
            ? 'Core components: producers write to partitioned topic logs, brokers replicate across nodes for durability, consumers read with offsets to enable replay. Kafka is the reference implementation. Key decisions: partition strategy affects parallelism, replication factor affects durability, retention policy affects storage. I\'d add a schema registry to enforce message contracts.'
            : 'SQL databases are relational, schema-enforced, ACID-compliant — great for structured data and complex queries. NoSQL trades some consistency for horizontal scalability and schema flexibility. Document stores (MongoDB) suit nested, varying structures. Key-value stores (Redis) for caching. Wide-column (Cassandra) for high-write time-series. I choose based on access patterns, consistency requirements, and scale.',
      ),
    ];
  }

  static List<InterviewQuestion> _dataQuestions(String seniority) {
    final isSeniorPlus = seniority == 'Senior' || seniority == 'Lead';
    return [
      const InterviewQuestion(
        category: QuestionCategory.technical,
        question: 'Explain the bias-variance tradeoff.',
        sampleAnswer:
            'Bias is error from wrong assumptions — a high-bias model underfits, failing to capture patterns. Variance is sensitivity to noise — a high-variance model overfits, memorizing training data. The tradeoff means reducing one often increases the other. Regularization, cross-validation, and ensemble methods help find the sweet spot. I always plot learning curves to diagnose which problem I\'m facing.',
      ),
      const InterviewQuestion(
        category: QuestionCategory.technical,
        question:
            'What is the difference between supervised, unsupervised, and reinforcement learning?',
        sampleAnswer:
            'Supervised learning trains on labeled input-output pairs to predict outputs for new inputs (classification, regression). Unsupervised learning finds structure in unlabeled data (clustering, dimensionality reduction). Reinforcement learning trains an agent through rewards and penalties in an environment — no labeled dataset, just feedback signals. Most production ML is supervised; unsupervised is valuable for exploration and preprocessing.',
      ),
      const InterviewQuestion(
        category: QuestionCategory.technical,
        question: 'How do you handle missing data and class imbalance?',
        sampleAnswer:
            'For missing data: impute with mean/median for numerical, mode for categorical, or use model-based imputation (KNN, iterative). Sometimes dropping rows or features is correct if data is not missing at random. For class imbalance: SMOTE synthesizes minority samples, class weighting adjusts the loss function, and threshold tuning optimizes the right metric (precision-recall over accuracy). I always evaluate with F1, AUC-ROC, or Cohen\'s kappa — not accuracy alone.',
      ),
      InterviewQuestion(
        category: QuestionCategory.technical,
        question: isSeniorPlus
            ? 'How do you design and monitor an ML system in production?'
            : 'Explain how gradient descent works.',
        sampleAnswer: isSeniorPlus
            ? 'Training pipeline: reproducible feature engineering, versioned datasets (DVC), experiment tracking (MLflow/Weights & Biases). Deployment: containerized model serving with shadow mode testing before cutover. Monitoring: data drift detection, prediction distribution shifts, business metric correlations. Retraining triggers on drift thresholds. I treat the model as a software artifact with CI/CD, not a one-time artifact.'
            : 'Gradient descent minimizes a loss function by iteratively moving parameters in the direction of the negative gradient. Batch GD uses the full dataset — slow but stable. Stochastic GD uses one sample — fast but noisy. Mini-batch GD is the practical middle ground. The learning rate controls step size; too high causes divergence, too low causes slow convergence. Adaptive optimizers like Adam adjust learning rates per parameter.',
      ),
      InterviewQuestion(
        category: QuestionCategory.technical,
        question: isSeniorPlus
            ? 'Describe your approach to feature engineering for a tabular dataset.'
            : 'What is cross-validation and why is it important?',
        sampleAnswer: isSeniorPlus
            ? 'I start with EDA to understand distributions and correlations. Then: encode categoricals (target encoding for high-cardinality), create interaction features for known domain relationships, apply log transforms to skewed numerics, extract temporal features from timestamps. Feature importance from a tree model guides pruning. I always validate new features improve CV score before including them.'
            : 'Cross-validation estimates model performance on unseen data. K-fold splits data into k folds, training on k-1 and validating on the held-out fold, rotating until each fold is used once. This reduces variance in the estimate compared to a single train/test split and uses data more efficiently. It\'s essential to detect overfitting before deployment.',
      ),
    ];
  }

  static List<InterviewQuestion> _devopsQuestions(String seniority) {
    final isSeniorPlus = seniority == 'Senior' || seniority == 'Lead';
    return [
      const InterviewQuestion(
        category: QuestionCategory.technical,
        question: 'What is the difference between CI and CD?',
        sampleAnswer:
            'Continuous Integration (CI) is the practice of merging code changes frequently and running automated tests on each merge. It catches integration bugs early. Continuous Delivery (CD) extends CI by automatically deploying every green build to staging — it\'s always ready to release. Continuous Deployment goes one step further: every green build goes to production automatically. Most teams practice CI + Continuous Delivery, with a manual approval gate to production.',
      ),
      const InterviewQuestion(
        category: QuestionCategory.technical,
        question: 'Explain Docker and container orchestration.',
        sampleAnswer:
            'Docker packages an application and its dependencies into a portable image. Containers are lightweight, isolated runtime instances of images. Without orchestration, you manage containers manually — not scalable. Kubernetes (k8s) automates deployment, scaling, and self-healing. Core concepts: Pods (one or more containers), Deployments (desired state), Services (networking), Ingress (routing). I use Helm charts for templated deployments.',
      ),
      const InterviewQuestion(
        category: QuestionCategory.technical,
        question:
            'What is infrastructure as code (IaC) and which tools have you used?',
        sampleAnswer:
            'IaC manages infrastructure through machine-readable configuration files instead of manual processes. Benefits: version control, repeatability, peer review, disaster recovery. Terraform is my primary tool — provider-agnostic, declarative, state-managed. Pulumi lets you use general-purpose languages. For AWS-specific work, CDK is powerful. The key principle: if it\'s not in code, it doesn\'t exist.',
      ),
      InterviewQuestion(
        category: QuestionCategory.technical,
        question: isSeniorPlus
            ? 'How do you design a zero-downtime deployment strategy?'
            : 'How do you approach monitoring and alerting for a production system?',
        sampleAnswer: isSeniorPlus
            ? 'Blue-green deployment: run two identical environments, switch traffic instantly and roll back by switching back. Canary deployment: route a small percentage of traffic to the new version, monitor error rates, gradually increase. Rolling deployment: replace instances one by one. I combine canary releases with feature flags for fine-grained control. Health checks and readiness probes prevent traffic from reaching unhealthy instances.'
            : 'I use the four golden signals: latency, traffic, errors, saturation. Prometheus scrapes metrics, Grafana visualizes them. Distributed tracing (Jaeger/Tempo) for request-level debugging. Structured logs in ELK stack. Alerts should be actionable — I avoid alert fatigue by alerting on SLO burn rate, not individual metric thresholds. On-call runbooks accompany every alert.',
      ),
      InterviewQuestion(
        category: QuestionCategory.technical,
        question: isSeniorPlus
            ? 'Describe how you would design a secure, scalable cloud architecture.'
            : 'What is a Kubernetes Pod and how does it differ from a container?',
        sampleAnswer: isSeniorPlus
            ? 'Start with defense in depth: network segmentation (VPCs, private subnets), least-privilege IAM, encrypted data at rest and in transit. Compute: auto-scaling groups or managed k8s. Data: managed databases with automated backups, multi-AZ. CDN for static assets. WAF at the edge. Secrets management via Vault or AWS Secrets Manager — never in environment variables or code.'
            : 'A container is a single runnable unit. A Pod is the smallest deployable unit in Kubernetes and wraps one or more tightly coupled containers that share network namespace and storage volumes. Containers in a Pod communicate via localhost. Sidecar patterns use this — a logging agent or service mesh proxy runs alongside the main container in the same Pod.',
      ),
    ];
  }

  static List<InterviewQuestion> _generalSweQuestions(String seniority) {
    final isSeniorPlus = seniority == 'Senior' || seniority == 'Lead';
    return [
      const InterviewQuestion(
        category: QuestionCategory.technical,
        question:
            'What is the difference between a stack and a queue? Give a use case for each.',
        sampleAnswer:
            'A stack is LIFO (Last In, First Out). Use cases: function call stack, undo/redo history, expression parsing. A queue is FIFO (First In, First Out). Use cases: task scheduling, BFS traversal, message queues. Both are fundamental to many algorithms and I reach for them when the access pattern matches their semantics.',
      ),
      const InterviewQuestion(
        category: QuestionCategory.technical,
        question:
            'Explain the time and space complexity of common sorting algorithms.',
        sampleAnswer:
            'QuickSort: O(n log n) average, O(n²) worst case, O(log n) space — fast in practice, used in most standard libraries. MergeSort: O(n log n) always, O(n) space — stable, predictable. HeapSort: O(n log n), O(1) space — not cache-friendly. BubbleSort/InsertionSort: O(n²) but O(n) for nearly sorted data — good for small or almost-sorted inputs. I choose based on data characteristics and stability requirements.',
      ),
      const InterviewQuestion(
        category: QuestionCategory.technical,
        question: 'What design patterns have you used? Describe one in detail.',
        sampleAnswer:
            'I use Observer frequently for event-driven systems — a subject maintains a list of observers and notifies them of state changes. It decouples producers from consumers. Repository pattern separates data access from business logic. Strategy pattern encapsulates interchangeable algorithms. Factory for object creation without specifying concrete classes. I treat patterns as vocabulary, not prescriptions — I apply them when the problem clearly fits.',
      ),
      InterviewQuestion(
        category: QuestionCategory.technical,
        question: isSeniorPlus
            ? 'How do you approach technical debt? When do you pay it down?'
            : 'How do you ensure code quality in your projects?',
        sampleAnswer: isSeniorPlus
            ? 'I distinguish between intentional debt (a conscious shortcut with a plan) and unintentional debt (bad decisions made unknowingly). I make debt visible — document it, track it in the backlog. I advocate for 20% of sprint capacity for quality work. I prioritize debt that blocks velocity or creates risk, not debt that\'s just aesthetically displeasing. Refactoring under test coverage prevents regressions.'
            : 'Code reviews catch logic errors and enforce standards. Linting and formatters (automated in CI) handle style. Unit tests for business logic, integration tests for system boundaries. I write tests before fixing bugs to prevent regressions. I keep functions small and single-purpose — if it\'s hard to test, it\'s a design smell.',
      ),
      InterviewQuestion(
        category: QuestionCategory.technical,
        question: isSeniorPlus
            ? 'Describe a complex system design you have worked on or would design for a URL shortener at scale.'
            : 'What is the difference between concurrency and parallelism?',
        sampleAnswer: isSeniorPlus
            ? 'URL shortener at scale: a write API generates a short code (base62 encoding of an auto-increment ID or a hash), stores the mapping in a key-value store like DynamoDB. A read API does a cache-first lookup (Redis), falls back to DB. CDN caches the redirect for popular URLs. Analytics events go to a Kafka stream processed asynchronously. With 100M URLs the DB fits comfortably — the challenge is read throughput, solved by the CDN and Redis.'
            : 'Concurrency is about dealing with multiple tasks at once — structuring a program to handle overlapping operations. Parallelism is about doing multiple tasks simultaneously using multiple cores. A single-core CPU can be concurrent (via context switching) but not truly parallel. Go\'s goroutines are concurrent; when run on multiple cores they also achieve parallelism. Understanding the distinction matters for reasoning about race conditions.',
      ),
    ];
  }

  // ─── Behavioral ───────────────────────────────────────────────────────────

  static List<InterviewQuestion> _behavioralQuestions(String seniority) {
    final isJunior = seniority == 'Junior';
    final isSeniorPlus = seniority == 'Senior' || seniority == 'Lead';
    final isLead = seniority == 'Lead';

    return [
      InterviewQuestion(
        category: QuestionCategory.behavioral,
        question: isJunior
            ? 'Tell me about a project you are most proud of.'
            : 'Tell me about the most impactful project you have delivered.',
        sampleAnswer: isJunior
            ? 'In my final year project, I built a task management app using Flutter. I was proud because I had to learn state management from scratch, hit real roadblocks with asynchronous data, and shipped a polished product. I learned to break problems into smaller pieces and the value of iterating based on peer feedback. It solidified my confidence in building full-featured apps.'
            : 'I led a migration of our monolith to a service-oriented architecture, reducing deploy frequency from weekly to multiple times daily. The impact was a 40% reduction in time-to-market for new features. The key challenge was doing it incrementally without disrupting the existing service. I used the strangler fig pattern — routing traffic gradually to new services while keeping the monolith as fallback.',
      ),
      InterviewQuestion(
        category: QuestionCategory.behavioral,
        question:
            'Describe a time you disagreed with a technical decision. How did you handle it?',
        sampleAnswer: isSeniorPlus
            ? 'My team decided to use a custom-built ORM despite available mature alternatives. I prepared a comparison document with benchmarks, maintenance cost estimates, and risk analysis. I presented it in the architecture review, not as criticism but as data. The team ultimately chose a hybrid: a lightweight wrapper built on a tested library. I\'ve learned that disagreements are won with evidence and lost with opinion.'
            : 'During a code review, I disagreed with a colleague\'s approach to caching that I believed would cause stale data issues. I raised it in the PR comments with a specific scenario where it would fail. We discussed it, and they explained a constraint I wasn\'t aware of. We found a solution together. I learned to ask clarifying questions before assuming my framing is complete.',
      ),
      const InterviewQuestion(
        category: QuestionCategory.behavioral,
        question:
            'Tell me about a time you had to meet a tight deadline. What did you do?',
        sampleAnswer:
            'We had a critical client demo in three days and a key feature was only 40% complete. I mapped out exactly what was needed for the demo versus a full implementation, cut scope to the essential path, and coordinated with the designer to simplify the UI. I communicated the adjusted scope to stakeholders upfront so there were no surprises. We delivered on time, and the client was impressed. I\'ve since made "what is the minimum to meet the goal" a standard question at the start of any high-pressure situation.',
      ),
      InterviewQuestion(
        category: QuestionCategory.behavioral,
        question: isLead
            ? 'How do you develop the technical skills of engineers on your team?'
            : 'Tell me about a time you received critical feedback. How did you respond?',
        sampleAnswer: isLead
            ? 'I do quarterly growth conversations to understand each engineer\'s goals. I match stretch assignments to those goals — not just staffing for efficiency. I run internal tech talks to normalize knowledge sharing. For junior engineers, I pair them with seniors on complex tasks rather than isolating them on simple ones. I track 30-60-90 day milestones and give direct, specific feedback in 1:1s rather than saving it for reviews.'
            : 'My manager told me my code reviews were too detailed on style and not enough on design. My initial reaction was defensive, but I sat with it. I reviewed my recent comments and saw the pattern — I was spending energy on things a linter should catch. I started using automated style checks and refocused reviews on architecture and correctness. Two months later my manager noted the improvement without me prompting it.',
      ),
      InterviewQuestion(
        category: QuestionCategory.behavioral,
        question: isSeniorPlus
            ? 'Describe how you handle ambiguous requirements or technical uncertainty.'
            : 'How do you prioritize when you have multiple tasks competing for your attention?',
        sampleAnswer: isSeniorPlus
            ? 'I treat ambiguity as a discovery problem. First I write down what I know, what I don\'t know, and what the impact of getting it wrong is. High-impact unknowns get time-boxed spikes — small experiments to reduce risk. I document assumptions explicitly and review them with stakeholders early. I\'d rather have a short alignment meeting than build in the wrong direction for a week.'
            : 'I list everything, then categorize by urgency and importance. Truly urgent and important tasks go first. I time-box tasks that tend to expand. I communicate proactively when I realize something will slip — early enough that it can be rescheduled, not at the deadline. I also protect blocks of focused time and batch context-switching tasks like emails and reviews.',
      ),
    ];
  }
}
