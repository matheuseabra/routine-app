import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from "@/components/ui/accordion";

const questions = [
  { question: "What is Routine?", answer: "Routine is a simple iPhone app for your daily tasks and habits. Bring the things you want to make time for into one place, check them off, and see your progress over time." },
  { question: "Do I need to have a routine already?", answer: "Not at all. Start with one small thing you’d like to do more often: a morning walk, a few pages, or a moment to stretch. You can add and edit your tasks as you find what works for you." },
  { question: "How do I track my progress?", answer: "Complete a task to record a check-in. The Habits tab shows what’s done and what’s next. Insights brings together your streak, active days, and completed tasks, with weekly and monthly views." },
  { question: "What if I miss a day?", answer: "Pick up with your next small step. Your previous check-ins remain part of your activity history, so you can look at your progress over a week or a month, even when a streak ends." },
  { question: "Is Routine available for Android?", answer: "Routine is designed for iPhone. An Android version is not currently available." },
];

export default function FAQ() {
  return (
    <Accordion type="single" collapsible className="faq-list">
      {questions.map(({ question, answer }, index) => (
        <AccordionItem key={question} value={`question-${index}`}>
          <AccordionTrigger className="py-6 text-base font-medium hover:no-underline">{question}</AccordionTrigger>
          <AccordionContent className="pb-6 text-[15px] leading-7 text-muted-foreground">{answer}</AccordionContent>
        </AccordionItem>
      ))}
    </Accordion>
  );
}
