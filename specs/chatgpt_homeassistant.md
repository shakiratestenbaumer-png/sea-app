Yes, programmable wall outlets already exist, and Home Assistant can automate them for free. This is important for your Swiss Energy Assistant idea because it means you don't need to manufacture smart switches or develop a home automation engine yourself.

In fact, I would consider Home Assistant an integration partner and an existing competitor, rather than something to replace.

## 1. Programmable smart outlets you can buy in Switzerland

There are two forms: plug-in adapters that fit an existing socket, and permanently installed smart relays or wall sockets.

For your initial experiments, plug-in adapters are much easier and safer.

[myStrom Energy Control Switch](https://images.openai.com/thumbnails/url/qe155HicDclLDoIwFADAEwEaDFYSY-qmEgkGg7A0WEo_2v9zwdJjehud7Xw_AsDFMsuYoWFxwKYEHmaV8ggjSJpSq7MorHPS8IPf_6_EzbQj9Cq0lJU6km3l824e1BoNgfXyeUGethyrES9CJfXrfntvzrTVImg1YNvoU93baPMZuoIUCP0AkrkvFw)

myStrom Energy Control Switch

CHF 36.00

Swiss Type J socket, Wi-Fi connectivity, power measurement, scheduling and local REST API. Rated up to 10 A, approximately 2,300 W.

My first choice for a Swiss prototype.

[Official developer API](https://mystrom.ch/mystrom-for-developers/?utm_source=chatgpt.com)&#x20;

[image](https://www.google.com/s2/favicons?domain=https://mystrom.ch\&sz=32)

myStrom+1



[Steffen Matter-Zwischenstecker T12 / T13](https://images.openai.com/thumbnails/url/bkNc0nicu9mYUVJSUGylr5-al1xUWVCSmqJbkpRnoJdeXJJYkpmsl5yfq1-ckV9QkJmXbl9oC5SzcvRLsXRPDsx2yw-vqCyvCslOS86I98g1STJL83D3jw8tC88y8sjLKE2rcAwxjMisysn0sMwsTnHK9y_PcvYryS3OtqwsKjfMdXILM3UOsQAAx58wJg)

Steffen Matter-Zwischenstecker T12 / T13

CHF 19.00

Swiss T12/T13 smart adapter with Matter connectivity. Suitable for testing schedules and interoperable home automation, subject to its electrical ratings and supported functions.

Economical Matter experiment.

[WiZ Smart Plug CH](https://images.openai.com/thumbnails/url/h3e6Pnicu9mYUVJSUGylr5-al1xUWVCSmqJbkpRnqJdeXJJYkpmsl5yfq1-ckV9QkJmXbl9oC5SzcvRLsXRPDnIsMEnND7c0Dqo0ya4KLTexcPXzKEoyCgjRNTQv96zwdos0cS0pNyhPKgo3dQuLcCx3qQo0qygwDo4v9Mpy9TIzNvaoNLdMtAAAVGctYQ)

WiZ Smart Plug CH

CHF 24.50

Swiss-format smart plug for app-based switching and schedules. A possible low-cost option, although I would verify its energy metering and local API capabilities before selecting it for development.

The myStrom plug is particularly interesting because its developer documentation explicitly allows local network control without a myStrom account or cloud service. Its local REST interface does not provide authentication by default, so it needs to remain on a trusted network rather than being exposed to the internet.&#x20;

[image](https://www.google.com/s2/favicons?domain=https://api.mystrom.ch\&sz=32)

myStrom



For permanent installations, there are also smart relays from Shelly and other manufacturers that can fit behind sockets or inside electrical cabinets. Those should be installed by an appropriately authorized electrician.

## 2. Can Home Assistant do everything your app proposes?

[Enphase Envoy on 2024.4 - Page 2 - Share your Projects! - Home Assistant Community](https://images.openai.com/static-rsc-4/dnS6lctjuLF3inuhG6trEAj56Nzgt1zyUopPZF6JmnU03NtnniG2lesssgRUIg4k0xOt21xPTKoLYs-FbyI2F2ygfl5gbdKUdsLxYsdPBm-dKutlp14em8fXw-oc71p4yYnf3Ww1JhWiEGGFTBK22P-wq3e0GDU9I7DGV9OycG8?purpose=inline)

Home Assistant

[Official website](https://www.home-assistant.io/?utm_source=chatgpt.com)

Home Assistant is free, open-source software supporting dashboards, notifications, connected devices, energy monitoring and automations. There are no software feature paywalls. Optional cloud services and dedicated hardware cost extra.&#x20;

[image](https://www.google.com/s2/favicons?domain=https://www.home-assistant.io\&sz=32)

Home Assistant



Here is how it compares to your planned app:

| Capability                                 | Home Assistant                          | Your proposed app     |
| ------------------------------------------ | --------------------------------------- | --------------------- |
| Show electricity prices                    | Yes, with suitable data integration     | Yes                   |
| Find cheapest hours                        | Yes, through integrations/configuration | Yes, automatic        |
| Notify when to run a dishwasher            | Yes                                     | Yes                   |
| Automatically control smart plugs          | Yes                                     | Later                 |
| Monitor solar and batteries                | Yes, compatible hardware                | Later                 |
| Swiss utility-specific billing comparisons | Requires suitable data/configuration    | Core differentiator   |
| Works without a home server                | Generally no                            | Yes                   |
| Setup for nontechnical customers           | Can be involved                         | Intended to be simple |
| Software cost                              | Free                                    | CHF 10/year proposed  |

Home Assistant already offers energy-price integrations and community extensions for finding the cheapest time windows and using solar surplus.&#x20;

[image](https://www.google.com/s2/favicons?domain=https://www.home-assistant.io\&sz=32)

Home Assistant+2



So the core algorithm itself is not unique.

But Home Assistant is a general-purpose home automation platform. Your advantage could be providing the Swiss electricity-specific experience in a much simpler form.

## 3. How much does Home Assistant really cost?

SOFTWARE

# Free

Open-source, with unlimited local automations and dashboards.

OPTIONAL DEDICATED HARDWARE

# €179

Home Assistant Green, suggested European retail price. Existing hardware can also be used.

Source: Home Assistant's official pricing and FAQ.&#x20;

[image](https://www.google.com/s2/favicons?domain=https://www.home-assistant.io\&sz=32)

Home Assistant+1

Since you already have a Raspberry Pi 5, you could run Home Assistant on that with no software subscription. Add a compatible smart plug and you can test automatic scheduling immediately.

You may still need a compatible Swiss tariff-data integration. A generic European wholesale-price integration doesn't automatically calculate the actual tariff billed by CKW, EKZ or another Swiss utility.

## 4. An important limitation: switching power isn't starting a machine

A programmable outlet can disconnect and restore power, but many washing machines, dryers and dishwashers won't start their programs automatically when power returns.

| Appliance                 | Smart plug usefulness                                          |
| ------------------------- | -------------------------------------------------------------- |
| Washing machine           | Mainly power monitoring; use built-in delayed start            |
| Dishwasher                | Mainly monitoring; use built-in delayed start                  |
| Tumble dryer              | Monitoring; avoid unattended remote-start workarounds          |
| EV charging               | Use supported charger control instead                          |
| Electric heater           | Possible only if rated, approved and safe for remote operation |
| Lighting and simple loads | Excellent                                                      |

For a 2,500 W appliance, a Swiss 10 A smart plug rated for approximately 2,300 W is not appropriate. Check the actual load, socket type, switching category and continuous-duty rating. Also, a higher-rated Schuko adapter is not automatically appropriate for a Swiss T13 outlet.

This actually reinforces your original idea: manual timing recommendations are a sensible first product, especially for kitchen and laundry appliances.

## 5. Could your app integrate with Home Assistant instead?

Yes, and this might be the best overall architecture.

You could offer two modes:

Standard mode — CHF 10/year: The app retrieves utility tariffs and tells users when to operate appliances. No smart-home hardware is required.

Connected mode — future option: Customers who already have Home Assistant could connect your tariff optimization engine to their existing automations. Your service would supply recommended schedules, while Home Assistant controls compatible devices locally.

This approach would avoid having to integrate hundreds of smart plugs, inverter models and controllers directly into your backend.

## 6. What I would test first

Since you have a Raspberry Pi 5 and experience with ESP32 and backend development, I'd run a small local proof of concept:

1. Install Home Assistant on the Pi.
2. Connect a Swiss myStrom smart plug.
3. Import sample 15-minute CKW/EKZ tariff schedules into your own FastAPI service.
4. Calculate the cheapest suitable operating window.
5. Publish the schedule to Home Assistant via a local API or MQTT.
6. Test switching with a simple lamp before integrating any higher-power appliance.

Then compare the experience with your own notification-only app.

My recommendation: Do not build your own hardware or compete with Home Assistant's automation capabilities. Build the Swiss tariff intelligence, personalized recommendations and simple mobile interface.

A Home Assistant integration can become a later feature, but it doesn't need to be part of the initial product.

The commercial opportunity remains the same: most customers don't want to configure a home automation server just to find out when they should run the dishwasher. A CHF 10/year app could serve them much more simply.