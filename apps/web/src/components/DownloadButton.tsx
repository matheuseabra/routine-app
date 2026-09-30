import * as React from "react";
import { FiSmartphone } from "react-icons/fi";
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle } from "@/components/ui/dialog";

export default function DownloadButton() {
  const [isOpen, setIsOpen] = React.useState(false);

  return (
    <>
      <div className="download-actions">
        <button className="download-button" type="button" onClick={() => setIsOpen(true)}>
          <FiSmartphone size={19} aria-hidden="true" />
          <span>Download app</span>
        </button>
      </div>
      <Dialog open={isOpen} onOpenChange={setIsOpen}>
        <DialogContent className="rounded-2xl p-8 sm:max-w-[420px]">
          <DialogHeader>
            <FiSmartphone className="mb-4" size={28} aria-hidden="true" />
            <DialogTitle className="text-2xl tracking-tight">Download link coming soon.</DialogTitle>
            <DialogDescription className="pt-3 text-base leading-7">The official Routine download link will be added here when it’s available.</DialogDescription>
          </DialogHeader>
        </DialogContent>
      </Dialog>
    </>
  );
}
