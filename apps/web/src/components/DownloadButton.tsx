import { ArrowUpRight, Smartphone } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";

// Set this public URL when a verified App Store or TestFlight listing is available.
const downloadURL = import.meta.env.PUBLIC_APP_DOWNLOAD_URL;

export default function DownloadButton() {
  const label = <><Smartphone size={18} aria-hidden="true" />Get Routine for iPhone<ArrowUpRight size={16} aria-hidden="true" /></>;
  if (downloadURL) {
    return <Button asChild className="download-button"><a href={downloadURL}>{label}</a></Button>;
  }
  return (
    <Dialog>
      <DialogTrigger asChild><Button className="download-button">{label}</Button></DialogTrigger>
      <DialogContent className="rounded-2xl p-8 sm:max-w-[420px]">
        <DialogHeader>
          <Smartphone className="mb-4" size={28} strokeWidth={1.5} aria-hidden="true" />
          <DialogTitle className="text-2xl tracking-tight">A little more Routine. Soon.</DialogTitle>
          <DialogDescription className="pt-3 text-base leading-7">We’re getting Routine ready for iPhone. Check back here for the download link when it’s available.</DialogDescription>
        </DialogHeader>
      </DialogContent>
    </Dialog>
  );
}
