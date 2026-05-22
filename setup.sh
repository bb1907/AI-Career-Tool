#!/bin/bash
set -e
echo "🚀 Kurulum başlıyor..."
mkdir -p lib/app/theme
mkdir -p lib/core/{config,errors,utils,widgets}
mkdir -p lib/features/auth/{data/repositories,domain/{entities,repositories},presentation/{controllers,pages}}
mkdir -p lib/features/home/presentation/pages
mkdir -p lib/features/onboarding/presentation/pages
mkdir -p lib/features/resume/{data/repositories,domain/{entities,repositories},presentation/{controllers,pages,widgets}}
mkdir -p lib/features/cover_letter/{data,domain,presentation}
mkdir -p lib/features/interview/{data,domain,presentation}
mkdir -p lib/features/{history,paywall,settings}
mkdir -p lib/services
echo "✅ Klasörler oluşturuldu"
