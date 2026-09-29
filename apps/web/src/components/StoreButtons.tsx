import * as React from "react";
import { FiSmartphone } from "react-icons/fi";
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle } from "@/components/ui/dialog";

export default function StoreButtons() {
  const [isOpen, setIsOpen] = React.useState(false);

  return (
    <>
      <div className="store-buttons" aria-label="Routine store availability">
        <button className="store-button" type="button" onClick={() => setIsOpen(true)} aria-label="App Store, Routine coming soon">
          <img src="/apple.svg" alt="" aria-hidden="true" />
          <span><small>Coming soon to the</small><strong>App Store</strong></span>
        </button>
        <button className="store-button" type="button" onClick={() => setIsOpen(true)} aria-label="Google Play, availability to be announced">
          <img src="/google.svg" alt="" aria-hidden="true" />
          <span><small>Availability to be announced</small><strong>Google Play</strong></span>
        </button>
      </div>
      <Dialog open={isOpen} onOpenChange={setIsOpen}>
        <DialogContent className="rounded-2xl p-8 sm:max-w-[420px]">
          <DialogHeader>
            <FiSmartphone className="mb-4" size={28} aria-hidden="true" />
            <DialogTitle className="text-2xl tracking-tight">Store links are coming.</DialogTitle>
            <DialogDescription className="pt-3 text-base leading-7">Routine isn’t available just yet. Check back here for the official store links.</DialogDescription>
          </DialogHeader>
        </DialogContent>
      </Dialog>
    </>
  );
}
