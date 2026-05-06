import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY')

serve(async (req) => {
  try {
    const payload = await req.json()
    console.log("Received notification payload:", JSON.stringify(payload))
    const { record } = payload

    if (!record || !record.user_id) {
      console.error("Invalid payload structure. Missing record or user_id.")
      throw new Error("Invalid notification record")
    }
    
    // 1. Initialize Supabase Client with service role
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // 2. Fetch User Email and Name
    const { data: user, error: userError } = await supabaseClient
      .from('users')
      .select('email, display_name')
      .eq('id', record.user_id)
      .single()

    if (userError || !user) {
      console.error(`Error fetching user for ID ${record.user_id}: ${userError?.message}`)
      return new Response(JSON.stringify({ error: "User not found" }), { status: 404 })
    }

    console.log(`Sending email to: ${user.email} (${user.display_name}) for notification: ${record.title}`)

    // 3. Send Email via Resend
    // Note: 'from' address must be verified in Resend. 'onboarding@resend.dev' works for testing.
    const res = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${RESEND_API_KEY}`,
      },
      body: JSON.stringify({
        from: 'VacanSee <onboarding@resend.dev>',
        to: [user.email],
        subject: `[VacanSee] ${record.title}`,
        html: `
          <!DOCTYPE html>
          <html>
          <body style="font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #f8fbfd; padding: 40px; margin: 0;">
            <div style="max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 12px rgba(0,0,0,0.05);">
              <div style="background-color: #5287B2; padding: 32px; text-align: center;">
                <h1 style="color: #ffffff; margin: 0; font-size: 24px;">VacanSee</h1>
              </div>
              <div style="padding: 40px; color: #333333; line-height: 1.6;">
                <h2 style="color: #1a1a1a; margin-top: 0;">Hello, ${user.display_name}!</h2>
                <p style="font-size: 16px;">${record.message}</p>
                <div style="margin-top: 32px; text-align: center;">
                  <a href="https://vacansee.vercel.app" style="background-color: #5287B2; color: #ffffff; padding: 12px 24px; text-decoration: none; border-radius: 8px; font-weight: 600; display: inline-block;">View in Dashboard</a>
                </div>
              </div>
              <div style="background-color: #f0f4f8; padding: 24px; text-align: center; font-size: 12px; color: #666666;">
                <p>&copy; 2026 VacanSee. All rights reserved.</p>
                <p>Cagayan de Oro City, Philippines</p>
              </div>
            </div>
          </body>
          </html>
        `,
      }),
    })

    const result = await res.json()
    
    if (!res.ok) {
      console.error(`Resend API Error details: ${JSON.stringify(result)}`)
      throw new Error(`Resend API Error: ${res.status} - ${JSON.stringify(result)}`)
    }

    return new Response(JSON.stringify({ success: true, message_id: result.id }), { 
      headers: { 'Content-Type': 'application/json' },
      status: 200 
    })
  } catch (error) {
    console.error(`Edge Function Failure: ${error.message}`)
    return new Response(JSON.stringify({ error: error.message }), { 
      headers: { 'Content-Type': 'application/json' },
      status: 500 
    })
  }
})
